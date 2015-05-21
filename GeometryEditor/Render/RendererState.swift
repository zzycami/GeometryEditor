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
        if render.vertexMultiPointGraphicId == InvalidId {
            render.vertexMultiPointGraphicId = render.addGraphic(render.core.ringEditor.getVertexMultiPoint(), attribute: GeometryEditorSymbols.NormalPointAttr, order: GeometryEditorRenderer.DRAW_ORDER_NORMAL_POINT)
        }else {
            render.updateGraphic(render.core.ringEditor.getVertexMultiPoint(), graphicId: render.vertexMultiPointGraphicId)
        }
    }
    
    func refreshActiveMidPoint(render:GeometryEditorRenderer) {
    }
    
    func refreshActiveStartEndPoint(render:GeometryEditorRenderer) {
    }
    
    func refreshActiveSelectionPoint(render:GeometryEditorRenderer) {
        if let point = render.sketchGraphicLayer.getSelectionPoint() {
            if render.selectionPointGraphicId == InvalidId {
                render.selectionPointGraphicId = render.addGraphic(point, attribute: GeometryEditorSymbols.SelectionAttr, order: GeometryEditorRenderer.DRAW_ORDER_SELECTION_POINT)
            }else {
                render.updateGraphic(point, graphicId: render.selectionPointGraphicId)
            }
        }else {
            if render.selectionPointGraphicId != InvalidId {
                render.removeGraphic(render.selectionPointGraphicId)
                render.selectionPointGraphicId = InvalidId
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
        if render.midMultiPointGraphicId == InvalidId {
            render.midMultiPointGraphicId = render.addGraphic(geometry, attribute: GeometryEditorSymbols.MidPointAttr, order: GeometryEditorRenderer.DRAW_ORDER_MID_POINT)
        }else {
            render.updateGraphic(geometry, graphicId: render.midMultiPointGraphicId)
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
            if render.startPointGraphicId == InvalidId {
                render.startPointGraphicId = render.addGraphic(point, attribute: GeometryEditorSymbols.StartPointAttr, order: GeometryEditorRenderer.DRAW_ORDER_START_POINT)
            }else {
                render.updateGraphic(point, graphicId: render.startPointGraphicId)
            }
        }else if render.startPointGraphicId != InvalidId {
            render.removeGraphic(render.startPointGraphicId)
            render.startPointGraphicId = InvalidId
        }
        
        if let point = endPoint {
            if render.endPointGraphicId == InvalidId {
                render.endPointGraphicId = render.addGraphic(point, attribute: GeometryEditorSymbols.EndPointAttr, order: GeometryEditorRenderer.DRAW_ORDER_END_POINT)
            }else {
                render.updateGraphic(point, graphicId: render.endPointGraphicId)
            }
        }else if render.endPointGraphicId != InvalidId {
            render.removeGraphic(render.endPointGraphicId)
            render.endPointGraphicId = InvalidId
        }
    }
}

class PolylineRendererState: MultiPathRendererState {
    override func refreshNonActive(render: GeometryEditorRenderer) {
        if let geometry = render.core.nonActiveGeometry {
            if render.nonActiveGeometryGraphicId == InvalidId {
                render.nonActiveGeometryGraphicId = render.addGraphic(geometry, attribute: GeometryEditorSymbols.NonActivePolylineAttr, order: GeometryEditorRenderer.DRAW_ORDER_NON_ACTIVE_GEOMETRY)
            }else {
                render.updateGraphic(geometry, graphicId: render.nonActiveGeometryGraphicId)
            }
        }
    }
    
    override func refreshActive(render: GeometryEditorRenderer) {
        var geometry = render.core.getActiveGeometry()
        if render.activeGeometryGraphicId == InvalidId {
            render.activeGeometryGraphicId = render.addGraphic(geometry, attribute: GeometryEditorSymbols.ActivePolylineAttr, order: GeometryEditorRenderer.DRAW_ORDER_MULTI_PATH)
        }else {
            render.updateGraphic(geometry, graphicId: render.activeGeometryGraphicId)
        }
    }
    
    override func getMidMultiPoint(ringEditor: RingEditor)->AGSGeometry {
        return ringEditor.getMidMultiPoint(false)
    }
}

class PolygonRendererState: MultiPathRendererState {
    override func refreshNonActive(render: GeometryEditorRenderer) {
        if let geometry = render.core.nonActiveGeometry {
            if render.nonActiveGeometryGraphicId == InvalidId {
                render.nonActiveGeometryGraphicId = render.addGraphic(geometry, attribute: GeometryEditorSymbols.NonActivePolygonAttr, order: GeometryEditorRenderer.DRAW_ORDER_NON_ACTIVE_GEOMETRY)
            }else {
                render.updateGraphic(geometry, graphicId: render.nonActiveGeometryGraphicId)
            }
        }
    }
    
    override func refreshActive(render: GeometryEditorRenderer) {
        var geometry = render.core.getActiveGeometry()
        if render.activeGeometryGraphicId == InvalidId {
            render.activeGeometryGraphicId = render.addGraphic(geometry, attribute: GeometryEditorSymbols.ActivePolygonAttr, order: GeometryEditorRenderer.DRAW_ORDER_MULTI_PATH)
        }else {
            render.updateGraphic(geometry, graphicId: render.activeGeometryGraphicId)
        }
    }
    
    override func getMidMultiPoint(ringEditor: RingEditor)->AGSGeometry {
        return ringEditor.getMidMultiPoint(false)
    }
}