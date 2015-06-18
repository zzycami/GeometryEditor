//
//  GeometryEditor.swift
//  GeometryEditor
//
//  Created by damingdan on 15/5/18.
//  Copyright (c) 2015年 kingoit. All rights reserved.
//

import UIKit
import ArcGIS


@objc
public enum GeometryMergeMode:Int {
    case Add
    case Subtract
}

@objc
public enum GeometryEditState:Int {
    case Normal
    case Insert
    case Move
}

@objc
public enum GeometryTypeMode:Int {
    case Point
    case Polygon
    case Polyline
}

public func GeometryTypeModeToEsriGeometryType(geometryTypeMode:GeometryTypeMode)->AGSGeometryType {
    switch geometryTypeMode {
    case .Point:
        return AGSGeometryType.Point
    case .Polygon:
        return AGSGeometryType.Polygon
    case .Polyline:
        return AGSGeometryType.Polyline
    }
}

@objc
public protocol GeometryEditorCallback:NSObjectProtocol {
    func onStart()
    func onStop()
    func onReset()
    func onStateChange(oldState:GeometryEditState, updateState:GeometryEditState)
}

@objc
public protocol GeometryEditorDelegate:NSObjectProtocol {
    optional func onStartEditGeometry(sketchGraphicsLayer:SketchGraphicsLayer)
    
    optional func onEditingGeometry(sketchGraphicsLayer:SketchGraphicsLayer, geometry:AGSGeometry, point:AGSPoint)
    
    optional func onFinishEditGeometry(sketchGraphicsLayer:SketchGraphicsLayer, geometry:AGSGeometry)
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
            
            self.handDrawModule = HandDrawModule(sketchGraphicsLayer: self)
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
    
    public func mapView(mapView: AGSMapView!, didEndTapAndHoldAtPoint screen: CGPoint, mapPoint mappoint: AGSPoint!, graphics: [NSObject : AnyObject]!) {
        if !touchable {
            return
        }
        println("onSingleTap, mapPoint:\(mappoint), mode:\(currentMode), state:\(state)")
        onPoint(mappoint)
    }
    
    
    public func onPoint(point:AGSPoint) {
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
        geometryEditorDelegate?.onEditingGeometry?(self, geometry: getGeometry(), point: point)
    }
    
    private func normalOnPoint(point:AGSPoint) {
        core.add(-1, point: point)
    }
    
    private func insertOnPoint(point:AGSPoint) {
        core.add(selectionPointIndex, point: point)
        self.state = GeometryEditState.Move
    }
    
    private func moveOnPoint(point:AGSPoint) {
        core.move(selectionPointIndex, point: point)
    }
    
    private func handleSelect(mapView:AGSMapView, point:AGSPoint)->Bool {
        var nearRadius = GeometryEditorPreferences.getNearRadius()
        var index = GeometryEditorUtils.getSelectIndex(point.x, y: point.y, points: core.ringEditor.getPoints(), mapView: mapView, nearRadius: nearRadius)
        if index >= 0 {
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
    public var geometryEditorDelegate:GeometryEditorDelegate?
    
    public var geometryEditorHost:GeometryEditorHost?
    
    public var geometryEditorCallBack:GeometryEditorCallback?
    
    private var core:GeometryEditorCore!
    
    private var geometryRender:GeometryEditorRenderer!
    
    private var selectionPointIndex:Int = -1
    
    private var state:GeometryEditState = GeometryEditState.Normal {
        didSet {
            if oldValue != state {
                geometryEditorCallBack?.onStateChange(oldValue, updateState: state)
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
    
    public var touchable:Bool = false {
        didSet {
            if self.mapView != nil {
                self.mapView.showMagnifierOnTapAndHold = touchable
            }
        }
    }
    
    public var isStart = false
    
    public var controlPanel:ControlPanel?
    
    public var handDrawModule:HandDrawModule?
    
    
    //MARK: Public Method
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
    
    
    
    private let DISTANCE_PER_DEGREE:Double = 111000
    public func bufferGeometryInternal(geometry:AGSGeometry)->AGSMutablePolygon? {
        if !isBufferEnable {
            return nil
        }
        var engine = AGSGeometryEngine.defaultGeometryEngine()
        var radius = self.bufferRadius
        if mapView.spatialReference.isWGS84() {
            radius = self.bufferRadius / DISTANCE_PER_DEGREE
            //self.mapView.spatialReference.convertValue(10, fromUnit: AGSSRUnit.UnitMeter)
        }
        return engine.bufferGeometry(geometry, byDistance: radius)
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
    
    public func mergeAdd()->Bool {
        if core.merge(GeometryMergeMode.Add) {
            cancelSelectInternal()
            geometryRender.refreshAll()
            return true
        }
        return false
    }
    
    public func mergeSubtract()->Bool {
        if core.merge(GeometryMergeMode.Subtract) {
            cancelSelectInternal()
            geometryRender.refreshAll()
            return true
        }
        return false
    }
    
    public func removeCurSelect() {
        if state != GeometryEditState.Move || selectionPointIndex < 0 {
            return
        }
        core.remove(selectionPointIndex)
        state = GeometryEditState.Normal
        selectionPointIndex = -1
        geometryRender.refreshActive()
    }
    
    public func setActivePoints(points:[AGSPoint]) {
        cancelSelectInternal()
        core.setActiveGeometry(points)
        geometryRender.refreshActive()
    }
    
    public func start() {
        if isStart {
            return
        }
        attach()
        touchable = true
        isStart = true
        geometryEditorCallBack?.onStart()
        geometryEditorDelegate?.onStartEditGeometry?(self)
    }
    
    public func stop() {
        if !isStart {
            return
        }
        detach()
        touchable = false
        resetState()
        isStart = false
        geometryEditorCallBack?.onStop()
        geometryEditorDelegate?.onFinishEditGeometry?(self, geometry: getGeometry())
    }
    
    public func reset() {
        resetState()
        resetData()
        geometryEditorCallBack?.onReset()
    }
    
    public func resetState() {
        if state == GeometryEditState.Normal {
            return
        }
        switch state {
        case .Insert:
            selectionPointIndex = -1
            break;
        case .Move:
            selectionPointIndex = -1
            break;
        default:
            break
        }
        state = GeometryEditState.Normal
        geometryRender.refreshActiveSelectionPoint()
    }
    
    public func attach() {
        geometryEditorHost?.onGeometryEditorAttach(self)
    }
    
    public func detach() {
        geometryEditorHost?.onGeometryEditorDetach(self)
    }
    
    public func getActiveGeometry()->AGSGeometry {
        return core.getActiveGeometry()
    }
    
    public func getNonActiveGeometry()->AGSGeometry? {
        return core.nonActiveGeometry
    }
    
    public func getGeometry()->AGSGeometry {
        var bufferGeometry = getBufferGeometry()
        if isBufferEnable && bufferGeometry != nil {
            return bufferGeometry!
        }
        return core.getGeometry()
    }
    
    public func getBufferGeometry()->AGSPolygon? {
        if core.isEmpty() {
            return nil
        }
        return bufferGeometryInternal(core.getGeometry())
    }
    
    public func setGeometry(geometry:AGSGeometry) {
        reset()
        core.setGeometry(geometry)
        geometryRender.refreshAll()
    }
    
    public func setPoints(points:[AGSPoint]) {
        reset()
        core.setPoints(points)
        geometryRender.refreshAll()
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
    
    private func resetData() {
        core.clear()
        geometryRender.clear()
    }
    
    private func setupBasicControlPanel() {
        if self.mapView != nil {
            var controlPanel = BasicControlPanel()
            controlPanel.bindSketchGraphicLayer(self)
            
            self.mapView.addSubview(controlPanel.controlPanelView!)
            var size = self.mapView.frame.size
            var width = controlPanel.getControlPanelWidth()
            var height = controlPanel.getControlPanelHeight()
            if size.width < width {
                width = size.width
            }
            controlPanel.controlPanelView?.snp_makeConstraints({ (make) -> Void in
                make.left.equalTo(self.mapView).offset(10)
                if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
                    make.top.equalTo(self.mapView).offset(50)
                }else {
                    make.top.equalTo(self.mapView).offset(10)
                }
                make.right.equalTo(self.mapView).offset(-10)
                make.height.equalTo(controlPanel.getControlPanelHeight())
            })
            
            self.controlPanel = controlPanel
        }
    }
}
