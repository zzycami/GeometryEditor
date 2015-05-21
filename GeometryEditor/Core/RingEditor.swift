//
//  RingEditor.swift
//  GeometryEditor
//
//  Created by damingdan on 15/5/18.
//  Copyright (c) 2015年 kingoit. All rights reserved.
//

import UIKit
import ArcGIS

/**
Update Operation type

- Add:    Add a point
- Remove: Remove a point
- Move:   move a point
*/
enum UpdateOpType:Int {
    case Add = 0
    case Remove = 1
    case Move = 2
}


class UpdateOp: NSObject {
    var type:UpdateOpType
    
    /// Update opsition, Add & Move is the after operation's position, Remove is the origin index.
    var index:Int
    
    var oldPoint:AGSPoint?
    var updatePoint:AGSPoint?
    
    init(type:UpdateOpType, index:Int, oldPoint:AGSPoint?, updatePoint:AGSPoint?) {
        self.type = type
        self.index = index
        self.oldPoint = oldPoint
        self.updatePoint = updatePoint
    }
}

class RingEditor: NSObject {
    // MARK: Property
    private var points:[AGSPoint] = []
    private var midPoints:[AGSPoint] = []
    
    private var polygon:AGSMutablePolygon
    private var polyline:AGSMutablePolyline
    
    private var vertexMultiPoint:AGSMutableMultipoint
    private var midMultiPoint:AGSMutableMultipoint
    
    private var historyUpdateOps:[UpdateOp] = []
    
    var spatialReference:AGSSpatialReference
    
    //MARK: Life Cycle
    init(spatialReference:AGSSpatialReference) {
        self.spatialReference = spatialReference
        polygon = AGSMutablePolygon(spatialReference: spatialReference)
        polyline = AGSMutablePolyline(spatialReference: spatialReference)
        vertexMultiPoint = AGSMutableMultipoint(spatialReference: spatialReference)
        midMultiPoint = AGSMutableMultipoint(spatialReference: spatialReference)
        super.init()
    }
    
    
    //MARK: Public Method
    func getPoints()->[AGSPoint] {
        let p = points
        return p
    }
    
    func getMidPoints()->[AGSPoint] {
        let mp = midPoints
        return mp
    }
    
    func getPolygon()->AGSPolygon {
        polygon = AGSMutablePolygon(spatialReference: spatialReference)
        GeometryEditorUtils.pointsToMultiPolygon(points, outMultiPolygon: &polygon)
        return polygon
    }
    
    func getPolyline()->AGSPolyline {
        polyline = AGSMutablePolyline(spatialReference: spatialReference)
        GeometryEditorUtils.pointsToMultiPolyline(points, outMultiPolyline: &polyline)
        return polyline
    }
    
    func getVertexMultiPoint()->AGSMultipoint {
        vertexMultiPoint = AGSMutableMultipoint(spatialReference: spatialReference)
        GeometryEditorUtils.pointsToMultiPoint(points, outMultiPoint: &vertexMultiPoint)
        return vertexMultiPoint
    }
    
    /**
    Get the mid point with @c AGSMultipoint
    
    :param: includeLast if include the last point, 
    the last point is the point which between the first point and the last point
    
    :returns:
    */
    func getMidMultiPoint(includeLast:Bool)->AGSMultipoint {
        midMultiPoint = AGSMutableMultipoint(spatialReference: spatialReference)
        var length = includeLast ? self.midPoints.count : self.midPoints.count - 1
        for var i = 0 ; i < length; i++ {
            var point = self.midPoints[i]
            midMultiPoint.addPoint(point)
        }
        return midMultiPoint
    }
    
    func getPointCount()->Int {
        return points.count
    }
    
    func isEmpty()->Bool {
        return points.isEmpty
    }
    
    func haveHistory()->Bool {
        return !historyUpdateOps.isEmpty
    }
    
    func setPoints(updatePoints:[AGSPoint]) {
        reset()
        if updatePoints.isEmpty {
            return
        }
        for point in updatePoints {
            points.append(point)
        }
        var pointA = updatePoints.first!
        var pointB:AGSPoint
        for i in 1...(updatePoints.count - 1) {
            pointB = updatePoints[i]
            midPoints.append(RingEditor.getMidPoint(pointA, pointB: pointB, spatialReference: spatialReference))
            pointA = pointB
        }
        if updatePoints.count > 1 {
            midPoints.append(RingEditor.getMidPoint(updatePoints.first!, pointB: updatePoints.last!, spatialReference: spatialReference))
        }
    }
    
    
    /**
    Add point at the end or in the middle
    
    :param: index     if -1 append at the end, or insert the point at position index
    :param: point     the point to be add
    :param: saveState if save this state
    
    :returns: if saveState is false, it will return nil
    */
    func add(index:Int, point:AGSPoint, saveState:Bool)->UpdateOp? {
        var oldSize = points.count
        var _index = index
        if _index < 0 {
            _index = oldSize
        }
        if oldSize > 1 {
            var midIndex = RingEditor.getRingIndex(_index - 1, length: oldSize)
            midPoints[midIndex] = RingEditor.getMidPoint(points[midIndex], pointB: point, spatialReference: spatialReference)
            midPoints.insert(RingEditor.getMidPoint(point, pointB: points[RingEditor.getRingIndex(_index, length: oldSize)], spatialReference: spatialReference), atIndex: _index)
        }else if oldSize == 1 {
            var midPoint = RingEditor.getMidPoint(points.first!, pointB: point, spatialReference: spatialReference)
            midPoints.append(midPoint)
            midPoints.append(AGSPoint(x: midPoint.x, y: midPoint.y, spatialReference: spatialReference))
        }
        
        points.insert(point, atIndex: _index)
        
        if saveState {
            var updateOp = UpdateOp(type: UpdateOpType.Add, index: _index, oldPoint: nil, updatePoint: point)
            historyUpdateOps.append(updateOp)
            return updateOp
        }
        return nil
    }
    
    func add(index:Int, point:AGSPoint)->UpdateOp?  {
        return add(index, point: point, saveState: true)
    }
    
    /**
    Remove Point
    
    :param: index     The position of the point to be removed
    :param: saveState if save this state
    
    :returns: if saveState is false, it will return nil
    */
    func remove(index:Int, saveState:Bool)->UpdateOp? {
        var oldSize = points.count
        if oldSize > 2 {
            var midIndex = RingEditor.getRingIndex(index - 1, length: oldSize)
            var a = points[midIndex]
            var b = points[RingEditor.getRingIndex(index + 1, length: oldSize)]
            midPoints[midIndex] = RingEditor.getMidPoint(a, pointB: b, spatialReference: spatialReference)
            midPoints.removeAtIndex(index)
        } else {
            midPoints.removeAll(keepCapacity: false)
        }
        
        var oldPoint = points.removeAtIndex(index)
        
        if saveState {
            var updateOp = UpdateOp(type: UpdateOpType.Remove, index: index, oldPoint: oldPoint, updatePoint: nil)
            historyUpdateOps.append(updateOp)
            return updateOp
        }
        return nil
    }
    
    func remove(index:Int)->UpdateOp? {
        return remove(index, saveState: true)
    }
    
    /**
    Move point
    
    :param: index     The position of the point to be moved
    :param: point     target point
    :param: saveState if save this state
    
    :returns: if saveState is false, it will return nil
    */
    func move(index:Int, point:AGSPoint, saveState:Bool)->UpdateOp? {
        var size = points.count
        if midPoints.isEmpty {
            var midIndex = RingEditor.getRingIndex(index - 1, length: size)
            midPoints[midIndex] = RingEditor.getMidPoint(points[midIndex], pointB: point, spatialReference: spatialReference)
            
            midPoints[index] = RingEditor.getMidPoint(point, pointB:points[RingEditor.getRingIndex(index + 1, length: size)], spatialReference: spatialReference)
        }
        var oldPoint = points[index]
        points[index] = point
        
        if saveState {
            var op = UpdateOp(type: UpdateOpType.Move, index: index, oldPoint: oldPoint, updatePoint: point)
            historyUpdateOps.append(op)
            return op
        }
        return nil
    }
    
    func move(index:Int, point:AGSPoint)->UpdateOp? {
        return move(index, point: point, saveState: true)
    }
    
    /**
    undo current operation
    
    :returns: The operation which is undo
    */
    func undo()->UpdateOp? {
        if historyUpdateOps.isEmpty {
            return nil
        }
        var op = historyUpdateOps.removeLast()

        switch op.type {
        case UpdateOpType.Add:
            op.type = UpdateOpType.Remove
            op.oldPoint = op.updatePoint
            op.updatePoint = nil
            remove(op.index, saveState: false)
            break
        case UpdateOpType.Remove:
            op.type = UpdateOpType.Add
            op.updatePoint = op.oldPoint
            op.oldPoint = nil
            add(op.index, point: op.updatePoint!, saveState: false)
            break
        case UpdateOpType.Move:
            var p = op.updatePoint
            op.updatePoint = op.oldPoint
            op.oldPoint = p
            move(op.index, point: op.updatePoint!, saveState: false)
            break
        }
        return op
    }
    
    func reset() {
        points.removeAll(keepCapacity: false)
        midPoints.removeAll(keepCapacity: false)
        historyUpdateOps.removeAll(keepCapacity: false)
        polyline = AGSMutablePolyline(spatialReference: spatialReference)
        polygon = AGSMutablePolygon(spatialReference: spatialReference)
        vertexMultiPoint = AGSMutableMultipoint(spatialReference: spatialReference)
        midMultiPoint = AGSMutableMultipoint(spatialReference: spatialReference)
    }
    
    
    static func getMidPoint(pointA:AGSPoint, pointB:AGSPoint, spatialReference:AGSSpatialReference)->AGSPoint {
        return AGSPoint(x: (pointA.x + pointB.x)/2, y: (pointA.y + pointB.y)/2, spatialReference: spatialReference)
    }
    
    /**
    Get the index at ring
    
    :param: index  original index at ring
    :param: length length shold >= 1
    
    :returns: 1.index < 0 : length -1; 2.index >= length : 0; 3.index
    */
    static func getRingIndex(index:Int, length:Int)->Int {
        if index < 0 {
            return length - 1
        }else if index >= length {
            return 0
        }
        return index
    }
}
