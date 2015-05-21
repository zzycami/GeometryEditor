//
//  GeometryEditor.swift
//  GeometryEditor
//
//  Created by damingdan on 15/5/18.
//  Copyright (c) 2015年 kingoit. All rights reserved.
//

import UIKit
import ArcGIS


@objc public enum GeometryMergeMode:Int {
    case Add
    case Subtract
}

@objc public enum GeometryEditState:Int {
    case Normal
    case Insert
    case Move
}

@objc public enum GeometryTypeMode:Int {
    case Point
    case Polygon
    case Polyline
}

@objc public protocol GeometryEditorCallback:NSObjectProtocol {
    func onStart()
    func onStop()
    func onReset()
    func onStateChange(oldState:GeometryEditState, updateState:GeometryEditState)
}


@objc public protocol GeometryEditorHost:NSObjectProtocol {
    func onGeometryEditorAttach(sketchLayer:SketchGraphicsLayer)
    
    func onGeometryEditorDetach(sketchLayer:SketchGraphicsLayer)
}

public class SketchGraphicsLayer: AGSGraphicsLayer, AGSMapViewTouchDelegate {
    //MARK: Life Cycle
    override init!(fullEnvelope fullEnv: AGSEnvelope!) {
        super.init(fullEnvelope: fullEnv)
        setupSketchGraphicsLayer()
    }
    
    override init!(fullEnvelope fullEnv: AGSEnvelope!, renderingMode: AGSGraphicsLayerRenderingMode) {
        super.init(fullEnvelope: fullEnv, renderingMode: renderingMode)
        setupSketchGraphicsLayer()
    }
    
    override init!(spatialReference sr: AGSSpatialReference!) {
        super.init(spatialReference: sr)
        setupSketchGraphicsLayer()
        
    }
    override init() {
        super.init()
        setupSketchGraphicsLayer()
    }
    
    func setupSketchGraphicsLayer() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "spatialReferenceDidReady:", name: AGSLayerDidInitializeSpatialReferenceStatusNotification, object: nil);
    }
    
    func spatialReferenceDidReady(notification:NSNotification) {
        var mapLayer = notification.object as! AGSLayer
        var spatialReference = mapLayer.spatialReference
        if spatialReference != nil {
            core = GeometryEditorCore(spatialReference: spatialReference)
            geometryRender = GeometryEditorRenderer(sketchGraphicLayer: self, core: core)
            self.currentMode = GeometryTypeMode.Polygon
            
            if controlPanel == nil {
                setupBasicControlPanel()
            }
        }
    }
    
    //MARK: Custom Delegate
    public func mapView(mapView: AGSMapView!, didClickAtPoint screen: CGPoint, mapPoint mappoint: AGSPoint!, graphics: [NSObject : AnyObject]!) {
        if !touchable {
            return
        }
        println("onSingleTap, mapPoint:\(mappoint), mode:\(currentMode), state:\(state)")
        
        if handleSelect(mapView, point: mappoint) {
            return
        }
        
        onPoint(mappoint)
    }
    
    private func onPoint(point:AGSPoint) {
        switch state {
        case .Normal:
            normalOnPoint(point)
            break
        case .Insert:
            insertOnPoint(point)
            break
        case .Move:
            moveOnPoint(point)
            break
        }
        geometryRender.refreshActive()
    }
    
    private func normalOnPoint(point:AGSPoint) {
        core.add(-1, point: point)
    }
    
    private func insertOnPoint(point:AGSPoint) {
        core.add(selectionPointIndex, point: point)
    }
    
    private func moveOnPoint(point:AGSPoint) {
        core.move(selectionPointIndex, point: point)
    }
    
    private func handleSelect(mapView:AGSMapView, point:AGSPoint)->Bool {
        var nearRadius = GeometryEditorPreferences.getNearRadius()
        var index = GeometryEditorUtils.getSelectIndex(point.x, y: point.y, points: core.ringEditor.getPoints(), mapView: mapView, nearRadius: nearRadius)
        if index > 0 {
            state = GeometryEditState.Move
            selectionPointIndex = index
        }else {
            var midePoints = core.ringEditor.getMidPoints()
            index = GeometryEditorUtils.getSelectIndex(point.x, y: point.y, points:midePoints , mapView: mapView, nearRadius: nearRadius)
            if index < 0 || (currentMode == GeometryTypeMode.Polyline && index == midePoints.count - 1) {
                return false
            }
            state = GeometryEditState.Insert
            selectionPointIndex = index + 1
        }
        geometryRender.refreshActiveSelectionPoint()
        return true
    }
    
    //MARK: Property
    public var geometryEditorHost:GeometryEditorHost?
    
    public var geometryEditorCallBack:GeometryEditorCallback?
    
    private var core:GeometryEditorCore!
    
    private var geometryRender:GeometryEditorRenderer!
    
    private var selectionPointIndex:Int = -1
    
    private var state:GeometryEditState = GeometryEditState.Normal {
        didSet {
            if oldValue != state {
                // TODO: notify state change
            }
        }
    }
    
    public var isBufferEnable:Bool = false
    
    public var bufferRadius:Double = 0 {
        didSet {
            geometryRender.refreshNonActiveBuffer()
        }
    }
    
    public var currentMode:GeometryTypeMode = GeometryTypeMode.Polygon {
        didSet {
            core.setMode(currentMode)
            geometryRender.setMode(currentMode)
            geometryRender.refreshAll()
        }
    }
    
    public var touchable:Bool = true
    
    public var controlPanel:ControlPanel?
    
    
    // Public Method
    public func getSelectionPoint()->AGSPoint? {
        if selectionPointIndex < 0 {
            return nil
        }
        if state == GeometryEditState.Move {
            return core.ringEditor.getPoints()[selectionPointIndex]
        }else {
            return core.ringEditor.getMidPoints()[selectionPointIndex - 1]
        }
    }
    
    public func bufferGeometryInternal(geometry:AGSGeometry)->AGSMutablePolygon {
        var engine = AGSGeometryEngine.defaultGeometryEngine()
        return engine.bufferGeometry(geometry, byDistance: bufferRadius)
    }
    
    public func cancelSelect() {
        if cancelSelectInternal() {
            geometryRender.refreshActiveSelectionPoint()
        }
    }
    
    public func undo()->Bool {
        var undoState = core.undo()
        if undoState == GeometryEditorUndoState.End {
            return false
        }
        
        if state != GeometryEditState.Normal {
            state = GeometryEditState.Normal
            selectionPointIndex = -1
        }
        
        if undoState == GeometryEditorUndoState.Active {
            geometryRender.refreshActive()
        }else {
            geometryRender.refreshAll()
        }
        return true
    }
    
    //MARK: Private Method
    private func cancelSelectInternal()->Bool {
        if state != GeometryEditState.Insert && state != GeometryEditState.Move {
            return false
        }
        state = GeometryEditState.Normal
        selectionPointIndex = -1
        return true
    }
    
    private func setupBasicControlPanel() {
        if self.mapView != nil {
            var controlPanel = BasicControlPanel()
            controlPanel.bindSketchGraphicLayer(self)
            
            self.mapView.addSubview(controlPanel.controlPanelView!)
            controlPanel.controlPanelView?.snp_makeConstraints({ (make) -> Void in
                make.left.equalTo(self.mapView).offset(10)
                make.top.equalTo(self.mapView).offset(20)
                make.width.equalTo(controlPanel.getControlPanelWidth())
                make.height.equalTo(controlPanel.getControlPanelHeight())
            })
            
            self.controlPanel = controlPanel
        }
    }
}
