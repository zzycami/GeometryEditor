//
//  RendererState.swift
//  GeometryEditor
//
//  Created by damingdan on 15/5/20.
//  Copyright (c) 2015年 kingoit. All rights reserved.
//

import UIKit
import ArcGIS

class RendererState: NSObject {
    func refreshNonActive(render:GeometryEditorRenderer) {
    }
    
    func refreshActive(render:GeometryEditorRenderer) {
    }
    
    func refreshActiveVertex(render:GeometryEditorRenderer) {
        if render.vertexMultiPointGraphic == nil {
            render.vertexMultiPointGraphic = render.addGraphic(render.core.ringEditor.getVertexMultiPoint(), attribute: GeometryEditorSymbols.NormalPointAttr, order: GeometryEditorRenderer.DRAW_ORDER_NORMAL_POINT)
        }else {
            render.updateGraphic(render.core.ringEditor.getVertexMultiPoint(), graphic: render.vertexMultiPointGraphic!)
        }
    }
    
    func refreshActiveMidPoint(render:GeometryEditorRenderer) {
    }
    
    func refreshActiveStartEndPoint(render:GeometryEditorRenderer) {
    }
    
    func refreshActiveSelectionPoint(render:GeometryEditorRenderer) {
        if let point = render.sketchGraphicLayer.getSelectionPoint() {
            if render.selectionPointGraphic == nil {
                render.selectionPointGraphic = render.addGraphic(point, attribute: GeometryEditorSymbols.SelectionAttr, order: GeometryEditorRenderer.DRAW_ORDER_SELECTION_POINT)
            }else {
                render.updateGraphic(point, graphic: render.selectionPointGraphic!)
            }
        }else {
            if render.selectionPointGraphic != nil {
                render.removeGraphic(render.selectionPointGraphic!)
                render.selectionPointGraphic = nil
            }
        }
    }
}

class MultiPointRendererState: RendererState {
    override func refreshActiveMidPoint(render:GeometryEditorRenderer) {
    }
    
    override func refreshActiveStartEndPoint(render:GeometryEditorRenderer) {
    }
    
    override func refreshNonActive(render:GeometryEditorRenderer) {
    }
    
    override func refreshActive(render:GeometryEditorRenderer) {
    }
}


class MultiPathRendererState: RendererState {
    func getMidMultiPoint(ringEditor:RingEditor)->AGSGeometry {
        return AGSGeometry(spatialReference: ringEditor.spatialReference)
    }
    
    override func refreshActiveMidPoint(render: GeometryEditorRenderer) {
        var geometry = getMidMultiPoint(render.core.ringEditor)
        if render.midMultiPointGraphic == nil {
            render.midMultiPointGraphic = render.addGraphic(geometry, attribute: GeometryEditorSymbols.MidPointAttr, order: GeometryEditorRenderer.DRAW_ORDER_MID_POINT)
        }else {
            render.updateGraphic(geometry, graphic: render.midMultiPointGraphic!)
        }
    }
    
    override func refreshActiveStartEndPoint(render: GeometryEditorRenderer) {
        // Get start point and end point
        var points = render.core.ringEditor.getPoints()
        var startPoint:AGSPoint?
        var endPoint:AGSPoint?
        
        if !points.isEmpty {
            startPoint = points.first
            if points.count > 1 {
                endPoint = points.last
            }
        }
        
        if let point = startPoint {
            if render.startPointGraphic == nil {
                render.startPointGraphic = render.addGraphic(point, attribute: GeometryEditorSymbols.StartPointAttr, order: GeometryEditorRenderer.DRAW_ORDER_START_POINT)
            }else {
                render.updateGraphic(point, graphic: render.startPointGraphic!)
            }
        }else if render.startPointGraphic != nil {
            render.removeGraphic(render.startPointGraphic!)
            render.startPointGraphic = nil
        }
        
        if let point = endPoint {
            if render.endPointGraphic == nil {
                render.endPointGraphic = render.addGraphic(point, attribute: GeometryEditorSymbols.EndPointAttr, order: GeometryEditorRenderer.DRAW_ORDER_END_POINT)
            }else {
                render.updateGraphic(point, graphic: render.endPointGraphic!)
            }
        }else if render.endPointGraphic != nil {
            render.removeGraphic(render.endPointGraphic!)
            render.endPointGraphic = nil
        }
    }
}

class PolylineRendererState: MultiPathRendererState {
    override func refreshNonActive(render: GeometryEditorRenderer) {
        if let geometry = render.core.nonActiveGeometry {
            if geometry.isValid() {
                if render.nonActiveGeometryGraphic == nil {
                    render.nonActiveGeometryGraphic = render.addGraphic(geometry, attribute: GeometryEditorSymbols.NonActivePolylineAttr, order: GeometryEditorRenderer.DRAW_ORDER_NON_ACTIVE_GEOMETRY)
                }else {
                    render.updateGraphic(geometry, graphic: render.nonActiveGeometryGraphic!)
                }
            }
        }
    }
    
    override func refreshActive(render: GeometryEditorRenderer) {
        var geometry = render.core.getActiveGeometry()
        if render.activeGeometryGraphic == nil {
            render.activeGeometryGraphic = render.addGraphic(geometry, attribute: GeometryEditorSymbols.ActivePolylineAttr, order: GeometryEditorRenderer.DRAW_ORDER_MULTI_PATH)
        }else {
            render.updateGraphic(geometry, graphic: render.activeGeometryGraphic!)
        }
    }
    
    override func getMidMultiPoint(ringEditor: RingEditor)->AGSGeometry {
        return ringEditor.getMidMultiPoint(false)
    }
}

class PolygonRendererState: MultiPathRendererState {
    override func refreshNonActive(render: GeometryEditorRenderer) {
        if let geometry = render.core.nonActiveGeometry {
            if render.nonActiveGeometryGraphic == nil {
                render.nonActiveGeometryGraphic = render.addGraphic(geometry, attribute: GeometryEditorSymbols.NonActivePolygonAttr, order: GeometryEditorRenderer.DRAW_ORDER_NON_ACTIVE_GEOMETRY)
            }else {
                render.updateGraphic(geometry, graphic: render.nonActiveGeometryGraphic!)
            }
        }
    }
    
    override func refreshActive(render: GeometryEditorRenderer) {
        var geometry = render.core.getActiveGeometry()
        if render.activeGeometryGraphic == nil {
            render.activeGeometryGraphic = render.addGraphic(geometry, attribute: GeometryEditorSymbols.ActivePolygonAttr, order: GeometryEditorRenderer.DRAW_ORDER_MULTI_PATH)
        }else {
            render.updateGraphic(geometry, graphic: render.activeGeometryGraphic!)
        }
    }
    
    override func getMidMultiPoint(ringEditor: RingEditor)->AGSGeometry {
        return ringEditor.getMidMultiPoint(true)
    }
}