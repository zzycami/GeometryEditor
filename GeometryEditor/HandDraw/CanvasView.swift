//
//  CavasView.swift
//  MobileMap
//
//  Created by damingdan on 15/4/9.
//  Copyright (c) 2015年 Kingoit. All rights reserved.
//

import UIKit
import ArcGIS

/**
*  This is a view shows the hand draw lines, and provide the points of line
*/
public class CanvasView: UIView {
    /// Path to draw
    private var path:UIBezierPath = UIBezierPath()
    
    /// Record the point for other data
    public var points:[CGPoint] = []
    
    var enable = false {
        didSet {
            self.userInteractionEnabled = enable
        }
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCanvasView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCanvasView()
    }
    
    func reset() {
        points = []
        path.removeAllPoints()
        self.setNeedsDisplay()
    }
    
    func setupCanvasView() {
        self.backgroundColor = UIColor.clearColor()
        path.lineWidth = 5
        path.lineCapStyle = kCGLineCapRound
        path.lineJoinStyle = kCGLineJoinRound
    }
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override public func drawRect(rect: CGRect) {
        UIColor.greenColor().set()
        path.stroke()
    }
    
    
    override public func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)  {
        var touch:UITouch = touches.first as! UITouch;
        addPointToPath(touch.locationInView(self))
    }
    
    override public func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch:UITouch = touches.first as! UITouch;
        addPointToPath(touch.locationInView(self))
    }
    
    override public func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch:UITouch = touches.first as! UITouch;
        addPointToPath(touch.locationInView(self))
    }
    
    override public func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        var touch:UITouch = touches.first as! UITouch;
        addPointToPath(touch.locationInView(self))
    }
    
    private func addPointToPath(point:CGPoint) {
        if !enable {
            return
        }
        
        // add point to path
        println("x:\(point.x), y:\(point.y)")
        if points.count == 0 {
            path.moveToPoint(point)
        }else {
            path.addLineToPoint(point)
        }
        points.append(point)
        self.setNeedsDisplay()
    }
    
}
