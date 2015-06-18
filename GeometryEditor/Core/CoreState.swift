//
//  CoreState.swift
//  GeometryEditor
//
//  Created by damingdan on 15/5/18.
//  Copyright (c) 2015年 kingoit. All rights reserved.
//

import Foundation
import ArcGIS


protocol CoreState:NSObjectProtocol {
    func merge( core:GeometryEditorCore, mergeMode:GeometryMergeMode)->Bool
    
    func getGeometry( core:GeometryEditorCore, mergeMode:GeometryMergeMode)->AGSGeometry
    
    func setGeometry( core:GeometryEditorCore, geometry:AGSGeometry)->Bool
    
    func createGeometry(spatialReference:AGSSpatialReference)->AGSGeometry
    
    /**
    *  Check the given geometry is current state's geometry
    */
    func checkGeometry(geometry:AGSGeometry)->Bool
    
    func changeActivePath( core:GeometryEditorCore, pathIndex:Int)->Bool
    
    func getActiveGeometry( core:GeometryEditorCore)->AGSGeometry
    
    /**
    *  Check can enter mergeMode
    */
    func checkMergeMode( core:GeometryEditorCore, mergeMode:GeometryMergeMode)->Bool
}

class PolygonState: NSObject, CoreState {
    
    func setGeometry( core: GeometryEditorCore, geometry: AGSGeometry)->Bool {
        if !checkGeometry(geometry) {
            return false
        }
        var nonActiveGeometry = core.nonActiveGeometry as? AGSPolygon
        if geometry.isEmpty() {
            nonActiveGeometry = AGSMutablePolygon(spatialReference: core.spatialReference)
        }else {
            var simplifyGeometry = AGSGeometryEngine.defaultGeometryEngine().simplifyGeometry(geometry)
            if simplifyGeometry.isValid() {
                core.nonActiveGeometry = simplifyGeometry
                nonActiveGeometry = simplifyGeometry as? AGSPolygon
            }else {
                nonActiveGeometry = geometry.copy() as? AGSPolygon
            }
        }
        
        if nonActiveGeometry?.numRings == 1 {
            changeActivePath(core, pathIndex: 0)
        }
        return true
    }
    
    
    func changeActivePath(core: GeometryEditorCore, pathIndex: Int) -> Bool {
        var nonActiveGeometry = core.nonActiveGeometry as? AGSPolygon
        if pathIndex < 0 || pathIndex >= nonActiveGeometry?.numRings {
            println("changeActivePath pathIndex < 0 || pathIndex >= geometry.getPathCount()")
            return false
        }
        core.addHistory();
        changeActivePathInternal(core, pathIndex: pathIndex);
        //TODO 应该判断正负环
        core.setMergeMode(GeometryMergeMode.Add);
        return true;
    }
    
    private func changeActivePathInternal(core: GeometryEditorCore, pathIndex: Int) {
        var nonActiveGeometry = core.nonActiveGeometry!.mutableCopy() as! AGSMutablePolygon
        var points = GeometryEditorUtils.polygonToPoints(nonActiveGeometry, pathIndex: pathIndex)
        core.ringEditor.setPoints(points)
        nonActiveGeometry.removeRingAtIndex(pathIndex)
        core.nonActiveGeometry = nonActiveGeometry
    }
    
    func merge( core: GeometryEditorCore, mergeMode: GeometryMergeMode) -> Bool {
        var nonActiveGeometry = core.nonActiveGeometry as? AGSPolygon
        if mergeMode == GeometryMergeMode.Subtract && (nonActiveGeometry != nil && nonActiveGeometry!.isEmpty()) {
            return false
        }
        core.addHistory()
        var ringEditor = core.ringEditor
        var mergeGeometry:AGSGeometry
        var engine = AGSGeometryEngine.defaultGeometryEngine()
        if mergeMode == GeometryMergeMode.Subtract {
            if nonActiveGeometry != nil &&  !nonActiveGeometry!.isEmpty() {
                mergeGeometry = engine.differenceOfGeometry(nonActiveGeometry, andGeometry: ringEditor.getPolygon())
            }else {
                mergeGeometry = createGeometry(core.spatialReference)
            }
        } else {
            if nonActiveGeometry != nil &&  !nonActiveGeometry!.isEmpty() {
                mergeGeometry = engine.differenceOfGeometry(nonActiveGeometry, andGeometry: ringEditor.getPolygon())
                mergeGeometry = engine.unionGeometries([mergeGeometry, ringEditor.getPolygon()])
            }else {
                mergeGeometry = ringEditor.getPolygon()
            }
        }
        core.nonActiveGeometry = mergeGeometry
        ringEditor.reset()
        return true
    }
    
    func getGeometry( core: GeometryEditorCore, mergeMode: GeometryMergeMode) -> AGSGeometry {
        var nonActiveGeometry = core.nonActiveGeometry as? AGSPolygon
        var ringEditor = core.ringEditor
        if ringEditor.isEmpty() {
            if let geometry = nonActiveGeometry {
                return geometry.copy() as! AGSGeometry
            }else {
                return self.createGeometry(core.spatialReference)
            }
        }
        var engine = AGSGeometryEngine.defaultGeometryEngine()
        if mergeMode == GeometryMergeMode.Subtract {
            return engine.differenceOfGeometry(nonActiveGeometry, andGeometry: ringEditor.getPolygon())
        }else {
            if let geometry = nonActiveGeometry {
                if geometry.isValid() {
                    return engine.unionGeometries([geometry, ringEditor.getPolygon()])
                }else {
                    return ringEditor.getPolygon()
                }
            }else {
                return ringEditor.getPolygon()
            }
        }
    }
    
    func createGeometry(spatialReference: AGSSpatialReference) -> AGSGeometry {
        return AGSPolygon(spatialReference: spatialReference)
    }
    
    func checkMergeMode( core: GeometryEditorCore, mergeMode: GeometryMergeMode) -> Bool {
        if mergeMode == GeometryMergeMode.Subtract && core.nonActiveGeometry!.isEmpty() {
            return false;
        }
        return true;
    }
    
    func getActiveGeometry(core: GeometryEditorCore) -> AGSGeometry {
        return core.ringEditor.getPolygon()
    }
    
    func checkGeometry(geometry: AGSGeometry) -> Bool {
        return geometry.isValid() || geometry.isKindOfClass(AGSPolygon)
    }
}

class PolylineState: NSObject, CoreState {
    func merge( core: GeometryEditorCore, mergeMode: GeometryMergeMode) -> Bool {
        core.addHistory()
        var engine = AGSGeometryEngine.defaultGeometryEngine()
        core.nonActiveGeometry = engine.unionGeometries([core.nonActiveGeometry!, core.ringEditor.getPolyline()])
        core.ringEditor.reset()
        return true
    }
    
    func getGeometry( core: GeometryEditorCore, mergeMode: GeometryMergeMode) -> AGSGeometry {
        var nonActiveGeometry = core.nonActiveGeometry as! AGSPolyline
        if core.ringEditor.isEmpty() {
            return nonActiveGeometry.copy() as! AGSGeometry
        }
        
        var engine = AGSGeometryEngine.defaultGeometryEngine()
        return engine.unionGeometries([nonActiveGeometry, core.ringEditor.getPolyline()])
    }
    
    func setGeometry( core: GeometryEditorCore, geometry: AGSGeometry) -> Bool {
        if !checkGeometry(geometry) {
            return false
        }
        var nonActiveGeometry = core.nonActiveGeometry as? AGSPolyline
        if geometry.isEmpty() {
            nonActiveGeometry = AGSMutablePolyline(spatialReference: core.spatialReference)
        }else {
            var simplifyGeometry = AGSGeometryEngine.defaultGeometryEngine().simplifyGeometry(geometry)
            if simplifyGeometry.isValid() {
                core.nonActiveGeometry = simplifyGeometry
                nonActiveGeometry = simplifyGeometry as? AGSPolyline
            }else {
                nonActiveGeometry = geometry.copy() as? AGSPolyline
            }
        }
        
        if nonActiveGeometry?.numPaths == 1 {
            changeActivePath(core, pathIndex: 0)
        }
        return true
    }
    
    func createGeometry(spatialReference: AGSSpatialReference) -> AGSGeometry {
        return AGSPolyline(spatialReference: spatialReference)
    }
    
    func checkMergeMode( core: GeometryEditorCore, mergeMode: GeometryMergeMode) -> Bool {
        return mergeMode == GeometryMergeMode.Add
    }
    
    func changeActivePath(core: GeometryEditorCore, pathIndex: Int) -> Bool {
        var nonActiveGeometry = core.nonActiveGeometry as! AGSPolyline
        if pathIndex < 0 || pathIndex >= nonActiveGeometry.numPaths {
            println("changeActivePath pathIndex < 0 || pathIndex >= geometry.getPathCount()")
            return false
        }
        core.addHistory();
        changeActivePathInternal(core, pathIndex: pathIndex);
        //TODO 应该判断正负环
        core.setMergeMode(GeometryMergeMode.Add);
        return true;
    }
    
    private func changeActivePathInternal(core: GeometryEditorCore, pathIndex: Int) {
        var nonActiveGeometry = core.nonActiveGeometry!.mutableCopy() as! AGSMutablePolyline
        var points = GeometryEditorUtils.polylineToPoints(nonActiveGeometry, pathIndex: pathIndex)
        core.ringEditor.setPoints(points)
        nonActiveGeometry.removePathAtIndex(pathIndex)
        core.nonActiveGeometry = nonActiveGeometry
    }
    
    func getActiveGeometry( core: GeometryEditorCore) -> AGSGeometry {
        return core.ringEditor.getPolyline()
    }
    
    func checkGeometry(geometry: AGSGeometry) -> Bool {
        return geometry.isValid() && geometry.isKindOfClass(AGSPolyline)
    }
}

class MultiPointState: NSObject, CoreState {
    func merge( core: GeometryEditorCore, mergeMode: GeometryMergeMode) -> Bool {
        return false
    }
    
    func getGeometry( core: GeometryEditorCore, mergeMode: GeometryMergeMode) -> AGSGeometry {
        return core.ringEditor.getVertexMultiPoint().copy() as! AGSGeometry
    }
    
    func setGeometry( core: GeometryEditorCore, geometry: AGSGeometry) -> Bool {
        if !checkGeometry(geometry) {
            return false
        }
        if !geometry.isValid() || geometry.isEmpty() {
            core.ringEditor.reset()
        }else {
            var points = GeometryEditorUtils.multiPointToPoints(geometry as! AGSMultipoint)
            core.ringEditor.setPoints(points)
        }
        return false
    }
    
    func createGeometry(spatialReference: AGSSpatialReference) -> AGSGeometry {
        return AGSMutablePoint(spatialReference: spatialReference)
    }
    
    func checkGeometry(geometry: AGSGeometry) -> Bool {
        return false
    }
    
    func changeActivePath( core: GeometryEditorCore, pathIndex: Int) -> Bool {
        return false
    }
    
    func getActiveGeometry( core: GeometryEditorCore) -> AGSGeometry {
        return core.ringEditor.getVertexMultiPoint()
    }
    
    func checkMergeMode( core: GeometryEditorCore, mergeMode: GeometryMergeMode) -> Bool {
        return false
    }
}