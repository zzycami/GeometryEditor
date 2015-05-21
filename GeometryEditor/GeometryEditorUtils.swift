//
//  GeometryEditorUtils.swift
//  GeometryEditor
//
//  Created by damingdan on 15/5/18.
//  Copyright (c) 2015年 kingoit. All rights reserved.
//

import UIKit
import ArcGIS

class GeometryEditorUtils: NSObject {
    /**
    Get the distance's squre of two point
    
    :param: x1 x of the first point
    :param: y1 y of the firest point
    :param: x2 x of the second point
    :param: y2 y of the second point
    */
    static func pointDistSq(x1:Double, y1:Double, x2:Double, y2:Double)->Double {
        return (x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2)
    }
    
    /**
    Get the index of the point in array points which is the nearest to the geiven point at radius
    
    :param: x          the x value of the given point
    :param: y          the y value of the given point
    :param: points     the point array contain serious points
    :param: mapView    the map view that contain this points
    :param: nearRadius the given radius
    
    :returns: the nearest point's index, if the value is -1 means do not exist such point
    */
    static func getSelectIndex(x:Double, y:Double, points:[AGSPoint], mapView:AGSMapView, nearRadius:Int)->Int {
        if points.count <= 0 {
            return -1
        }
        var index = -1
        var point:AGSPoint
        var dist:Double
        var minDist:Double = Double(MAXFLOAT)
        for var i=0; i<points.count; i++ {
            point = points[i]
            var tempX = point.x - x
            var tempY = point.y - y
            dist = tempX*tempX + tempY*tempY
            if dist < minDist {
                index = i
                minDist = dist
            }
        }
        if isNear(minDist, nearRadius: nearRadius, resolution: mapView.resolution) {
            return index
        }
        return -1
    }
    
    /**
    Check the distance in the map view at current resolution < 1px
    
    :param: distSq     square of distance in map view
    :param: nearRadius
    :param: resolution
    
    :returns:
    */
    static func isNear(distSq:Double, nearRadius:Int, resolution:Double)->Bool {
        return distSq < Double(nearRadius)*Double(nearRadius)*resolution*resolution
    }
    
    static func pointsToMultiPolygon(points:[AGSPoint], inout outMultiPolygon:AGSMutablePolygon) {
        if points.isEmpty {
            return
        }
        outMultiPolygon.addRingToPolygon()
        for point in points {
            outMultiPolygon.addPointToRing(point)
        }
    }
    
    static func pointsToMultiPolyline(points:[AGSPoint], inout outMultiPolyline:AGSMutablePolyline) {
        if points.isEmpty {
            return
        }
        outMultiPolyline.addPathToPolyline()
        for point in points {
            outMultiPolyline.addPointToPath(point)
        }
    }
    
    static func pointsToMultiPoint(points:[AGSPoint], inout outMultiPoint:AGSMutableMultipoint) {
        if points.isEmpty {
            return
        }
        for point in points {
            outMultiPoint.addPoint(point)
        }
    }
    
    static func polygonToPoints(polygon:AGSPolygon, pathIndex:Int)->[AGSPoint] {
        var points:[AGSPoint] = []
        var count:Int
        if pathIndex < 0 {
            count = polygon.numPoints()
        }else {
            count = polygon.numPointsInRing(pathIndex)
        }
        for var i=0; i<count; i++ {
            points.append(polygon.pointOnRing(pathIndex, atIndex: i))
        }
        return points
    }
    
    static func polylineToPoints(polyline:AGSPolyline, pathIndex:Int)->[AGSPoint] {
        var points:[AGSPoint] = []
        var count:Int
        if pathIndex < 0 {
            count = polyline.numPaths
        }else {
            count = polyline.numPointsInPath(pathIndex)
        }
        for var i = 0; i < count; i++ {
            points.append(polyline.pointOnPath(pathIndex, atIndex: i))
        }
        return points
    }
    
    static func multiPointToPoints(multiPoint:AGSMultipoint)->[AGSPoint] {
        var points:[AGSPoint] = []
        for var i = 0;i < multiPoint.numPoints; i++ {
            points.append(multiPoint.pointAtIndex(i))
        }
        return points
    }
}
