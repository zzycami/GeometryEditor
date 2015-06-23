//
//  GeometryEditorCore.swift
//  GeometryEditor
//
//  Created by damingdan on 15/5/18.
//  Copyright (c) 2015年 kingoit. All rights reserved.
//

import UIKit
import ArcGIS


enum GeometryEditorUndoState {
    case Active
    case All
    case End
}

class HistoryData: NSObject {
    var geometry:AGSGeometry?
    var points:[AGSPoint]
    var mergeMode:GeometryMergeMode
    
    init(geometry:AGSGeometry?, points:[AGSPoint], mergeMode:GeometryMergeMode) {
        self.geometry = geometry
        self.points = points
        self.mergeMode = mergeMode
        super.init()
    }
}

class GeometryEditorCore: NSObject {
    private var currentState:CoreState!
    
    var ringEditor:RingEditor
    var nonActiveGeometry:AGSGeometry?
    
    var spatialReference: AGSSpatialReference
    
    private var currentMergeMode = GeometryMergeMode.Add
    
    private var coreHistoryStack:[HistoryData] = []
    
    init(spatialReference:AGSSpatialReference) {
        self.spatialReference = spatialReference
        ringEditor = RingEditor(spatialReference: spatialReference)
        super.init()
    }
    
    
    func setMode(mode:GeometryTypeMode) {
        switch mode {
        case .Point:
            currentState = MultiPointState()
            break
        case .Polygon:
            currentState = PolygonState()
            break
        case .Polyline:
            currentState = PolylineState()
            break
        }
        //nonActiveGeometry = currentState.createGeometry(spatialReference)

        currentMergeMode = GeometryMergeMode.Add
        coreHistoryStack.removeAll(keepCapacity: false)
    }
    
    /**
    merge current editing part to other active part
    
    :param: mergeMode merge mode
    
    :returns: operation success?
    */
    func merge(mergeMode:GeometryMergeMode)->Bool {
        if ringEditor.isEmpty() {
            return false
        }
        return currentState.merge(self, mergeMode: mergeMode)
    }
    
    func merge()->Bool {
        return merge(currentMergeMode)
    }
    
    /**
    get current editing geometry
    
    :param: mergeMode merge mode
    
    :returns: current editing geometry
    */
    func getGeometry(mergeMode:GeometryMergeMode)->AGSGeometry {
        return currentState.getGeometry(self, mergeMode: GeometryMergeMode.Add)
    }
    
    
    func getGeometry()->AGSGeometry {
        return getGeometry(currentMergeMode)
    }
    
    func setGeometry(geometry:AGSGeometry)->Bool {
        coreHistoryStack.removeAll(keepCapacity: false)
        return currentState.setGeometry(self, geometry: geometry)
    }
    
    func setPoints(points:[AGSPoint]) {
        coreHistoryStack.removeAll(keepCapacity: false)
        nonActiveGeometry = AGSGeometry(spatialReference: spatialReference)
        ringEditor.setPoints(points)
    }
    
    func clear() {
        nonActiveGeometry = nil
        ringEditor.reset()
        coreHistoryStack.removeAll(keepCapacity: false)
    }
    
    func isActivePathChanged()->Bool {
        return ringEditor.haveHistory()
    }
    
    func changeActivePath(pathIndex:Int)->Bool {
        return currentState.changeActivePath(self, pathIndex: pathIndex)
    }
    
    func undo()->GeometryEditorUndoState {
        if ringEditor.haveHistory() {
            ringEditor.undo()
            return GeometryEditorUndoState.Active
        }
        if !coreHistoryStack.isEmpty {
            var history = coreHistoryStack.removeLast()
            nonActiveGeometry = history.geometry
            ringEditor.setPoints(history.points)
            currentMergeMode = history.mergeMode
            return GeometryEditorUndoState.All
        }
        return GeometryEditorUndoState.End
    }
    
    func addHistory() {
        coreHistoryStack.append(HistoryData(geometry: nonActiveGeometry?.copy() as? AGSGeometry, points: ringEditor.getPoints(), mergeMode: currentMergeMode))
    }
    
    func add(index:Int, point:AGSPoint) {
        ringEditor.add(index, point: point)
    }
    
    func remove(index:Int) {
        ringEditor.remove(index)
    }
    
    func move(index:Int, point:AGSPoint) {
        ringEditor.move(index, point: point)
    }
    
    func getActiveGeometry()->AGSGeometry {
        return currentState.getActiveGeometry(self)
    }
    
    func setMergeMode(mergeMode:GeometryMergeMode)->Bool {
        if currentState.checkMergeMode(self, mergeMode: mergeMode) {
            currentMergeMode = mergeMode
            return true
        }
        return false
    }
    
    func isEmpty()->Bool {
        if let geometry = self.nonActiveGeometry {
            return ringEditor.isEmpty() && (nonActiveGeometry == nil || geometry.isEmpty())
        }else {
            return ringEditor.isEmpty() && nonActiveGeometry == nil
        }
    }
    
    func setActiveGeometry(points:[AGSPoint]) {
        ringEditor.setPoints(points)
    }
}
