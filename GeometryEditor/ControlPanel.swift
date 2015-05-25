//
//  ControlPanel.swift
//  GeometryEditorExampleSwift
//
//  Created by damingdan on 15/5/21.
//  Copyright (c) 2015年 kingoit. All rights reserved.
//

import UIKit

public class ControlPanel: NSObject, GeometryEditorCallback {
    var sketchGraphicsLayer:SketchGraphicsLayer!
    
    var controlPanelView:UIView?
    
    public var visible:Bool = false {
        didSet {
            if let view = self.controlPanelView {
                view.hidden = !visible
            }
        }
    }
    
    
    public init(controlPanelView:UIView?) {
        super.init()
        self.controlPanelView = controlPanelView
    }
    
    internal func bindSketchGraphicLayer(sketchGraphicsLayer:SketchGraphicsLayer) {
        self.sketchGraphicsLayer = sketchGraphicsLayer
        self.sketchGraphicsLayer.geometryEditorCallBack = self
        self.controlPanelView?.hidden = true
    }
    
    
    
    public func onStart() {
        visible = true
    }
    
    public func onStop() {
        visible = false
    }
    
    public func onReset() {
        
    }
    
    public func onStateChange(oldState: GeometryEditState, updateState: GeometryEditState) {
        
    }
    
    public func showHandDrawPanel(show:Bool) {
    }
}
