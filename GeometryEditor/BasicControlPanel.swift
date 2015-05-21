//
//  BasicControlPanel.swift
//  GeometryEditorExampleSwift
//
//  Created by damingdan on 15/5/21.
//  Copyright (c) 2015年 kingoit. All rights reserved.
//

import UIKit

public class BasicControlPanel:ControlPanel {
    public var deselectBtn:UIButton = UIButton(frame: CGRectZero)
    private var deselectLabel:UILabel = UILabel(frame: CGRectZero)
    
    public var removeBtn:UIButton = UIButton(frame: CGRectZero)
    private var removeLabel:UILabel = UILabel(frame: CGRectZero)
    
    public var undoBtn:UIButton = UIButton(frame: CGRectZero)
    private var undoLabel:UILabel = UILabel(frame: CGRectZero)
    
    public var gpsBtn:UIButton = UIButton(frame: CGRectZero)
    private var gpsLabel:UILabel = UILabel(frame: CGRectZero)
    
    public var coordinateInputBtn:UIButton = UIButton(frame: CGRectZero)
    private var coordinateInputLabel:UILabel = UILabel(frame: CGRectZero)
    
    public var handDrawBtn:UIButton = UIButton(frame: CGRectZero)
    private var handDrawLabel:UILabel = UILabel(frame: CGRectZero)
    
    public var pathRecordBtn:UIButton = UIButton(frame: CGRectZero)
    private var pathRecordLabel:UILabel = UILabel(frame: CGRectZero)
    
    public var mergeAddBtn:UIButton = UIButton(frame: CGRectZero)
    private var mergeAddLabel:UILabel = UILabel(frame: CGRectZero)
    
    public var mergeSubtractBtn:UIButton = UIButton(frame: CGRectZero)
    private var mergeSubtractLabel:UILabel = UILabel(frame: CGRectZero)
    
    public var bufferBtn:UIButton = UIButton(frame: CGRectZero)
    public var bufferLabel:UILabel = UILabel(frame: CGRectZero)
    
    private var btnContainer:UIView = UIView(frame: CGRectZero)
    private var handDrawBtnContainer:UIView = UIView(frame: CGRectZero)
    
    public init() {
        super.init(controlPanelView: nil)
        setupView()
    }
    
    private var buttons:[UIButton] = []
    private var labels:[UILabel] = []
    
    public var padding:CGFloat = 5
    
    public let buttonWidth:CGFloat = 39
    
    private func setupView() {
        
        deselectBtn.setImage(UIImage(named: "icon_control_cancer"), forState: UIControlState.Normal)
        deselectBtn.addTarget(self, action: "cancelSelect:", forControlEvents: UIControlEvents.TouchUpInside)
        deselectLabel.text = "取消"
        
        removeBtn.setImage(UIImage(named: "icon_control_remove"), forState: UIControlState.Normal)
        removeBtn.addTarget(self, action: "removeCurSelect:", forControlEvents: UIControlEvents.TouchUpInside)
        removeLabel.text = "删除点"
        
        undoBtn.setImage(UIImage(named: "icon_control_undo"), forState: UIControlState.Normal)
        undoBtn.addTarget(self, action: "undo:", forControlEvents: UIControlEvents.TouchUpInside)
        undoLabel.text = "撤销"
        
        gpsBtn.setImage(UIImage(named: "icon_control_gps"), forState: UIControlState.Normal)
        gpsBtn.addTarget(self, action: "singleGps:", forControlEvents: UIControlEvents.TouchUpInside)
        gpsLabel.text = "GPS"
        
        coordinateInputBtn.setImage(UIImage(named: "icon_control_input"), forState: UIControlState.Normal)
        coordinateInputBtn.addTarget(self, action: "coordinateInput:", forControlEvents: UIControlEvents.TouchUpInside)
        coordinateInputLabel.text = "输入点"
        
        handDrawBtn.setImage(UIImage(named: "icon_hand_draw"), forState: UIControlState.Normal)
        handDrawBtn.addTarget(self, action: "startHandDraw:", forControlEvents: UIControlEvents.TouchUpInside)
        handDrawLabel.text = "手绘"
        
        pathRecordBtn.setImage(UIImage(named: "icon_control_path"), forState: UIControlState.Normal)
        pathRecordBtn.addTarget(self, action: "startPathRecord:", forControlEvents: UIControlEvents.TouchUpInside)
        pathRecordLabel.text = "轨迹"
        
        mergeAddBtn.setImage(UIImage(named: "icon_control_add"), forState: UIControlState.Normal)
        mergeAddBtn.addTarget(self, action: "mergeAdd:", forControlEvents: UIControlEvents.TouchUpInside)
        mergeAddLabel.text = "加"
        
        mergeSubtractBtn.setImage(UIImage(named: "icon_control_minus"), forState: UIControlState.Normal)
        mergeSubtractBtn.addTarget(self, action: "mergeSubtract:", forControlEvents: UIControlEvents.TouchUpInside)
        mergeSubtractLabel.text = "减"
        
        bufferBtn.setImage(UIImage(named: "icon_control_oval"), forState: UIControlState.Normal)
        bufferBtn.addTarget(self, action: "removeCurSelect:", forControlEvents: UIControlEvents.TouchUpInside)
        bufferLabel.text = "缓冲区"
        
        buttons = [undoBtn, mergeAddBtn, mergeSubtractBtn,  deselectBtn, removeBtn, gpsBtn, coordinateInputBtn, handDrawBtn, pathRecordBtn, bufferBtn]
        
        labels = [undoLabel, mergeAddLabel, mergeSubtractLabel,  deselectLabel, removeLabel, gpsLabel, coordinateInputLabel, handDrawLabel, pathRecordLabel, bufferLabel]
        
        controlPanelView = UIView(frame: CGRectMake(0, 0, getControlPanelWidth(), getControlPanelHeight()))
        
        var prevView:UIView?
        for i in 0..<(buttons.count) {
            var button = buttons[i]
            var label = labels[i]
            
            button.setBackgroundImage(UIImage(named: "background_control_selected"), forState: UIControlState.Normal)
            button.setBackgroundImage(UIImage(named: "background_control_normal"), forState: UIControlState.Highlighted)
            
            controlPanelView?.addSubview(button)
            button.snp_makeConstraints({ (make) -> Void in
                if let view = prevView {
                    make.leading.equalTo(view.snp_trailing).offset(self.padding)
                }else {
                    make.leading.equalTo(self.controlPanelView!)
                }
                make.width.equalTo(self.buttonWidth)
                make.height.equalTo(self.buttonWidth)
                make.centerY.equalTo(self.controlPanelView!).offset(10)
                prevView = button
            })
            
            label.font = UIFont.systemFontOfSize(13)
            label.textColor = UIColor.blueColor()
            label.textAlignment = NSTextAlignment.Center
            controlPanelView?.addSubview(label)
            label.snp_makeConstraints({ (make) -> Void in
                make.centerX.equalTo(button)
                make.top.equalTo(button.snp_bottom)
            })
        }
    }
    
    public func getControlPanelHeight()->CGFloat {
        return 60
    }
    
    public func getControlPanelWidth()->CGFloat {
        var width:CGFloat = CGFloat(buttons.count)*buttonWidth + CGFloat(buttons.count - 1)*padding
        return width
    }
    
    public func cancelSelect(sender:UIButton) {
        sketchGraphicsLayer.cancelSelect()
    }
    
    public func undo(sender:UIButton) {
        sketchGraphicsLayer.undo()
    }
    
    public func removeCurSelect(sender:UIButton) {
        sketchGraphicsLayer.removeCurSelect()
    }
    
    public func singleGps(sender:UIButton) {
    }
    
    public func coordinateInput(sender:UIButton) {
    }
    
    public func startHandDraw(sender:UIButton) {
    }
    
    public func startPathRecord(sender:UIButton) {
    }
    
    public func buffer(sender:UIButton) {
    }
    
    public func mergeAdd(sender:UIButton) {
        sketchGraphicsLayer.mergeAdd()
    }
    
    public func mergeSubtract(sender:UIButton) {
        sketchGraphicsLayer.mergeSubtract()
    }
}
