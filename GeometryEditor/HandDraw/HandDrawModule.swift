//
//  HandDrawModule.swift
//  GeometryEditorExampleSwift
//
//  Created by damingdan on 15/5/22.
//  Copyright (c) 2015年 kingoit. All rights reserved.
//

import UIKit
import ArcGIS

class HandDrawModule: NSObject {
    var sketchGraphicsLayer:SketchGraphicsLayer
    
    var canvasView:CanvasView = CanvasView(frame: CGRectZero)
    
    var isStart = false
    
    init(sketchGraphicsLayer:SketchGraphicsLayer) {
        self.sketchGraphicsLayer = sketchGraphicsLayer
    }
    
    func start() {
        var subviews = sketchGraphicsLayer.mapView.subviews as! [UIView]
        if let index = find(subviews, canvasView) {
            canvasView.enable = true
            canvasView.hidden = false
        }else {
            sketchGraphicsLayer.mapView.addSubview(canvasView)
            sketchGraphicsLayer.mapView.insertSubview(canvasView, belowSubview: sketchGraphicsLayer.controlPanel!.controlPanelView!)
            canvasView.snp_makeConstraints({ (make) -> Void in
                make.edges.equalTo(self.sketchGraphicsLayer.mapView)
            })
            canvasView.enable = true
        }
        sketchGraphicsLayer.controlPanel?.showHandDrawPanel(true)
        canvasView.reset()
        isStart = true
    }
    
    func stop() {
        if !isStart {
            return
        }
        sketchGraphicsLayer.controlPanel?.showHandDrawPanel(false)
        canvasView.enable = false
        canvasView.hidden = true
        isStart = false
    }
    
    func clear() {
        canvasView.reset()
    }
    
    func complete() {
        var points = canvasView.points
        if !points.isEmpty {
            var esriPoints = thinning(points)
            sketchGraphicsLayer.setActivePoints(esriPoints)
        }
        stop()
    }
    
    private let minStepSq:CGFloat = 40
    
    private func thinning(points:[CGPoint])->[AGSPoint] {
        var results:[AGSPoint] = []
        if points.isEmpty {
            return results
        }
        
        var firstPoint = points.first!
        results.append(sketchGraphicsLayer.mapView.toMapPoint(firstPoint))
        var lastPoint = points.last!
        if lastPoint == firstPoint {
            return results
        }
        var prevPoint = firstPoint
        var curPoint:CGPoint = CGPointZero
        for i in 1..<points.count {
            curPoint = points[i]
            var tempX:CGFloat = prevPoint.x - curPoint.x
            var tempY:CGFloat = prevPoint.y - curPoint.y
            var distaceSqual = tempX*tempX + tempY*tempY
            if distaceSqual >= minStepSq {
                results.append(sketchGraphicsLayer.mapView.toMapPoint(curPoint))
                prevPoint = curPoint
            }
        }
        
        if !CGPointEqualToPoint(prevPoint, curPoint) && !CGPointEqualToPoint(firstPoint, curPoint) {
            results.append(sketchGraphicsLayer.mapView.toMapPoint(curPoint))
        }
        
        return results
    }
}
