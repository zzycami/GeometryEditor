//
//  GeometryEditorRenderer.swift
//  GeometryEditor
//
//  Created by damingdan on 15/5/20.
//  Copyright (c) 2015年 kingoit. All rights reserved.
//

import UIKit
import ArcGIS

let InvalidId = -1

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
    
    
    var nonActiveGeometryGraphicId = InvalidId
    var activeGeometryGraphicId = InvalidId
    var vertexMultiPointGraphicId = InvalidId
    var midMultiPointGraphicId = InvalidId
    var startPointGraphicId = InvalidId
    var endPointGraphicId = InvalidId
    var selectionPointGraphicId = InvalidId
    var nonActiveBufferGraphicId = InvalidId
    
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
        nonActiveGeometryGraphicId = InvalidId
        activeGeometryGraphicId = InvalidId
        vertexMultiPointGraphicId = InvalidId
        midMultiPointGraphicId = InvalidId
        startPointGraphicId = InvalidId
        endPointGraphicId = InvalidId
        selectionPointGraphicId = InvalidId
        nonActiveBufferGraphicId = InvalidId
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
                if nonActiveBufferGraphicId == InvalidId {
                    nonActiveBufferGraphicId = addGraphic(geometry, attribute: GeometryEditorSymbols.BufferAttr, order: GeometryEditorRenderer.DRAW_ORDER_BUFFER)
                }else {
                    updateGraphic(geometry, graphicId: nonActiveBufferGraphicId)
                }
            }
        }else if nonActiveBufferGraphicId != InvalidId {
            removeGraphic(nonActiveBufferGraphicId)
            nonActiveBufferGraphicId = InvalidId
        }
    }
    
    func addGraphic(geometry:AGSGeometry, attribute:[String:String], order:Int)->Int {
        var graphic = AGSGraphic(geometry: geometry, symbol: nil, attributes: attribute)
        graphic.drawIndex = UInt(order)
        self.sketchGraphicLayer.addGraphic(graphic)
        self.sketchGraphicLayer.refresh()
        return find(self.sketchGraphicLayer.graphics as! [AGSGraphic], graphic)!
    }
    
    func updateGraphic(geometry:AGSGeometry, graphicId:Int) {
        var graphic = self.sketchGraphicLayer.graphics[graphicId] as! AGSGraphic
        graphic.geometry = geometry
        sketchGraphicLayer.refresh()
    }
    
    func removeGraphic(graphicId:Int) {
        var graphic = self.sketchGraphicLayer.graphics[graphicId] as! AGSGraphic
        self.sketchGraphicLayer.removeGraphic(graphic)
        self.sketchGraphicLayer.refresh()
    }
}
