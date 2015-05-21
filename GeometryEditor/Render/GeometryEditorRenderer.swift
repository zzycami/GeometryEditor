//
//  GeometryEditorRenderer.swift
//  GeometryEditor
//
//  Created by damingdan on 15/5/20.
//  Copyright (c) 2015年 kingoit. All rights reserved.
//

import UIKit
import ArcGIS

class GeometryEditorRenderer: NSObject {
    
    //各部分图形绘图顺序
    static let DRAW_ORDER_NON_ACTIVE_GEOMETRY = 0
    static let DRAW_ORDER_BUFFER = 1
    static let DRAW_ORDER_MULTI_PATH = 2
    static let DRAW_ORDER_MID_POINT = 3
    static let DRAW_ORDER_NORMAL_POINT = 4
    static let DRAW_ORDER_START_POINT = 5
    static let DRAW_ORDER_END_POINT = DRAW_ORDER_START_POINT
    static let DRAW_ORDER_SELECTION_POINT = 6
    
    
    var nonActiveGeometryGraphic:AGSGraphic?
    var activeGeometryGraphic:AGSGraphic?
    var vertexMultiPointGraphic:AGSGraphic?
    var midMultiPointGraphic:AGSGraphic?
    var startPointGraphic:AGSGraphic?
    var endPointGraphic:AGSGraphic?
    var selectionPointGraphic:AGSGraphic?
    var nonActiveBufferGraphic:AGSGraphic?
    
    var sketchGraphicLayer:SketchGraphicsLayer
    var core:GeometryEditorCore
    
    private var currentRenderState:RendererState?
    
    init(sketchGraphicLayer:SketchGraphicsLayer, core:GeometryEditorCore) {
        self.sketchGraphicLayer = sketchGraphicLayer
        self.sketchGraphicLayer.renderer = GeometryEditorSymbols.createRender()
        self.core = core
        super.init()
    }
    
    func setMode(mode:GeometryTypeMode) {
        if currentRenderState != nil {
            clear()
        }
        switch mode {
        case .Point:
            currentRenderState = MultiPointRendererState()
            break
        case .Polygon:
            currentRenderState = PolygonRendererState()
            break
        case .Polyline:
            currentRenderState = PolylineRendererState()
            break
        }
    }
    
    func clear() {
        sketchGraphicLayer.removeAllGraphics()
        nonActiveGeometryGraphic = nil
        activeGeometryGraphic = nil
        vertexMultiPointGraphic = nil
        midMultiPointGraphic = nil
        startPointGraphic = nil
        endPointGraphic = nil
        selectionPointGraphic = nil
        nonActiveBufferGraphic = nil
    }
    
    func refreshAll() {
        refreshNonActive()
        refreshActive()
    }
    
    func refreshNonActive() {
        currentRenderState?.refreshNonActive(self)
        refreshNonActiveBuffer()
    }
    
    func refreshActive() {
        refreshActiveGeometry()
        refreshActiveMidPoint()
        refreshActiveVertex()
        refreshActiveStartEndPoint()
        refreshActiveSelectionPoint()
    }
    
    func refreshActiveGeometry() {
        currentRenderState?.refreshActive(self)
    }
    
    func refreshActiveVertex() {
        currentRenderState?.refreshActiveVertex(self)
    }
    
    func refreshActiveMidPoint() {
        currentRenderState?.refreshActiveMidPoint(self)
    }
    
    func refreshActiveStartEndPoint() {
        currentRenderState?.refreshActiveStartEndPoint(self)
    }
    
    func refreshActiveSelectionPoint() {
        currentRenderState?.refreshActiveSelectionPoint(self)
    }
    
    func refreshNonActiveBuffer() {
        if sketchGraphicLayer.isBufferEnable {
            var nonActiveGeometry = core.nonActiveGeometry
            var bufferGeometry = nonActiveGeometry
            
            if let geometry = nonActiveGeometry {
                if !geometry.isEmpty() {
                    bufferGeometry = sketchGraphicLayer.bufferGeometryInternal(geometry)
                }
                if nonActiveBufferGraphic == nil {
                    nonActiveBufferGraphic = addGraphic(geometry, attribute: GeometryEditorSymbols.BufferAttr, order: GeometryEditorRenderer.DRAW_ORDER_BUFFER)
                }else {
                    updateGraphic(geometry, graphic: nonActiveBufferGraphic!)
                }
            }
        }else if nonActiveBufferGraphic != nil {
            removeGraphic(nonActiveBufferGraphic!)
            nonActiveBufferGraphic = nil
        }
    }
    
    func addGraphic(geometry:AGSGeometry, attribute:[String:String], order:Int)->AGSGraphic {
        var graphic = AGSGraphic(geometry: geometry, symbol: nil, attributes: attribute)
        graphic.drawIndex = UInt(order)
        self.sketchGraphicLayer.addGraphic(graphic)
        self.sketchGraphicLayer.refresh()
        return graphic
    }
    
    func updateGraphic(geometry:AGSGeometry, graphic:AGSGraphic) {
        graphic.geometry = geometry
        sketchGraphicLayer.refresh()
    }
    
    func removeGraphic(graphic:AGSGraphic) {
        self.sketchGraphicLayer.removeGraphic(graphic)
        self.sketchGraphicLayer.refresh()
    }
}
