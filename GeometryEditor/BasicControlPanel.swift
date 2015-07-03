//
//  BasicControlPanel.swift
//  GeometryEditorExampleSwift
//
//  Created by damingdan on 15/5/21.
//  Copyright (c) 2015年 kingoit. All rights reserved.
//

import UIKit

@objc
public enum BasicControlPanelStyle:Int {
    case Acquisition
    case Normal
    case Simple
}

public class BasicControlPanel:ControlPanel, LocationUtilsDelegate, CutManagerCallback {
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
    
    private var btnContainer:UIScrollView = UIScrollView(frame: CGRectZero)
    private var handDrawBtnContainer:UIView = UIView(frame: CGRectZero)
    
    private var handDrawCompleteBtn:UIButton = UIButton(frame: CGRectZero)
    private var handDrawCompleteLabel:UILabel = UILabel(frame: CGRectZero)
    
    private var handDrawCancelBtn:UIButton = UIButton(frame: CGRectZero)
    private var handDrawCancelLabel:UILabel = UILabel(frame: CGRectZero)
    
    private var handDrawClearBtn:UIButton = UIButton(frame: CGRectZero)
    private var handDrawClearLabel:UILabel = UILabel(frame: CGRectZero)
    
    public var cutBtn:UIButton = UIButton(frame: CGRectZero)
    private var cutLabel:UILabel = UILabel(frame: CGRectZero)
    
    public var mergeBtn:UIButton = UIButton(frame: CGRectZero)
    private var mergeLabel:UILabel = UILabel(frame: CGRectZero)
    
    public var nearLineBtn:UIButton = UIButton(frame: CGRectZero)
    private var nearLineLabel:UILabel = UILabel(frame: CGRectZero)
    
    private var locationUtils:LocationUtils!
    private var isSingleLocating = false
    private var isPathRecord = false
    public var acquisitionCutManager:AcquisitionCutManager?
    public var acquisitionMergeManager:AcquisitionMergeManager?
    
    public var style:BasicControlPanelStyle = BasicControlPanelStyle.Normal {
        didSet {
            if oldValue != self.style {
                if style == BasicControlPanelStyle.Acquisition {
                    self.buttons = [undoBtn, mergeAddBtn, mergeSubtractBtn,  deselectBtn, removeBtn, coordinateInputBtn, gpsBtn, pathRecordBtn,handDrawBtn, bufferBtn, cutBtn, mergeBtn]
                    self.labels = [undoLabel, mergeAddLabel, mergeSubtractLabel,  deselectLabel, removeLabel, coordinateInputLabel, gpsLabel, pathRecordLabel,handDrawLabel, bufferLabel, cutLabel, mergeLabel]
                }else if style == BasicControlPanelStyle.Normal {
                    self.buttons = [undoBtn, mergeAddBtn, mergeSubtractBtn,  deselectBtn, removeBtn, coordinateInputBtn, gpsBtn, pathRecordBtn,handDrawBtn]
                    self.labels = [undoLabel, mergeAddLabel, mergeSubtractLabel,  deselectLabel, removeLabel, coordinateInputLabel, gpsLabel, pathRecordLabel,handDrawLabel, bufferLabel]
                    self.cutBtn.removeFromSuperview()
                    self.cutLabel.removeFromSuperview()
                    self.mergeBtn.removeFromSuperview()
                    self.mergeLabel.removeFromSuperview()
                    self.nearLineBtn.removeFromSuperview()
                    self.nearLineLabel.removeFromSuperview()
                }
                
                setupConstrains(buttons, labels: labels, containerView: btnContainer)
            }
        }
    }
    
    public init() {
        super.init(controlPanelView: nil)
        setupView()
    }
    
    public override func onStop() {
        super.onStop()
        setCutStart(false)
    }

    
    override func bindSketchGraphicLayer(sketchGraphicsLayer: SketchGraphicsLayer) {
        super.bindSketchGraphicLayer(sketchGraphicsLayer)
        locationUtils = LocationUtils(mapView: sketchGraphicsLayer.mapView)
        locationUtils.delegate = self
        
        self.removeBtn.enabled = false
        self.deselectBtn.enabled = false
    }
    
    public override func onStart() {
        super.onStart()
        self.removeBtn.enabled = false
        self.deselectBtn.enabled = false
        
        if sketchGraphicsLayer.currentMode == GeometryTypeMode.Point {
            self.mergeAddBtn.enabled = false
            self.mergeSubtractBtn.enabled = false
        }else if sketchGraphicsLayer.currentMode == GeometryTypeMode.Polyline {
            self.mergeSubtractBtn.enabled = false
            self.mergeAddBtn.enabled = true
        }else if sketchGraphicsLayer.currentMode == GeometryTypeMode.Polygon {
            self.mergeSubtractBtn.enabled = true
            self.mergeAddBtn.enabled = true
        }
    }
    
    public override func onSelectPoint() {
        self.removeBtn.enabled = true
        self.deselectBtn.enabled = true
    }
    
    private var buttons:[UIButton] = []
    private var labels:[UILabel] = []
    
    public func addButton(button:UIButton, label:UILabel) {
        buttons.append(button)
        labels.append(label)
    }
    
    public func removeButton(button:UIButton, label:UILabel) {
        if let index1 = find(self.buttons, button), let index2 = find(self.labels, label) {
            self.buttons.removeAtIndex(index1)
            self.labels.removeAtIndex(index2)
        }
    }
    
    public var padding:CGFloat = 5
    
    public let buttonWidth:CGFloat = 45
    
    public func setupView() {
        buttons = [undoBtn, mergeAddBtn, mergeSubtractBtn,  deselectBtn, removeBtn, coordinateInputBtn, gpsBtn, pathRecordBtn,handDrawBtn, bufferBtn]
        
        labels = [undoLabel, mergeAddLabel, mergeSubtractLabel,  deselectLabel, removeLabel, coordinateInputLabel, gpsLabel, pathRecordLabel,handDrawLabel, bufferLabel]
        
        controlPanelView = UIView(frame: CGRectZero)
        controlPanelView?.userInteractionEnabled = true
        
        
        setupHandDrawButtons()
        handDrawBtnContainer = UIView(frame: CGRectZero)
        handDrawBtnContainer.userInteractionEnabled = true
        controlPanelView!.addSubview(handDrawBtnContainer)
        handDrawBtnContainer.snp_makeConstraints({ (make) -> Void in
            make.edges.equalTo(self.controlPanelView!)
        })
        var handDrawButtons = [handDrawClearBtn, handDrawCancelBtn, handDrawCompleteBtn]
        var handDrawLabels = [handDrawClearLabel, handDrawCancelLabel, handDrawCompleteLabel]
        setupConstrains(handDrawButtons, labels: handDrawLabels, containerView: handDrawBtnContainer)
        
        handDrawBtnContainer.hidden = true
        
        setupButtons()
        btnContainer = UIScrollView(frame: CGRectZero)
        var contentSize = CGSizeMake(getControlPanelWidth(), getControlPanelHeight())
        btnContainer.contentSize = contentSize
        btnContainer.showsHorizontalScrollIndicator = false
        btnContainer.userInteractionEnabled = true
        controlPanelView!.addSubview(btnContainer)
        btnContainer.snp_makeConstraints({ (make) -> Void in
            make.edges.equalTo(self.controlPanelView!)
        })
        setupConstrains(buttons, labels: labels, containerView: btnContainer)
    }
    
    private func setupHandDrawButtons() {
        handDrawCompleteBtn.setImage(UIImage(named: "icon_control_save"), forState: UIControlState.Normal)
        handDrawCompleteBtn.addTarget(self, action: "handDrawComplete:", forControlEvents: UIControlEvents.TouchUpInside)
        handDrawCompleteLabel.text = "完成"
        
        handDrawCancelBtn.setImage(UIImage(named: "icon_control_cancer"), forState: UIControlState.Normal)
        handDrawCancelBtn.addTarget(self, action: "handDrawCancel:", forControlEvents: UIControlEvents.TouchUpInside)
        handDrawCancelLabel.text = "取消"
        
        handDrawClearBtn.setImage(UIImage(named: "icon_control_delete"), forState: UIControlState.Normal)
        handDrawClearBtn.addTarget(self, action: "handDrawClear:", forControlEvents: UIControlEvents.TouchUpInside)
        handDrawClearLabel.text = "清除"
    }
    
    private func setupButtons() {
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
        bufferBtn.addTarget(self, action: "buffer:", forControlEvents: UIControlEvents.TouchUpInside)
        bufferLabel.text = "缓冲区"
        
        cutBtn.setImage(UIImage(named: "icon_control_cut"), forState: UIControlState.Normal)
        cutBtn.addTarget(self, action: "geometryCut:", forControlEvents: UIControlEvents.TouchUpInside)
        cutLabel.text = "分割"
        
        mergeBtn.setImage(UIImage(named: "icon_control_merge"), forState: UIControlState.Normal)
        mergeBtn.addTarget(self, action: "geometryMerge:", forControlEvents: UIControlEvents.TouchUpInside)
        mergeLabel.text = "合并"
        
        nearLineBtn.setImage(UIImage(named: "icon_control_sorption"), forState: UIControlState.Normal)
        nearLineBtn.addTarget(self, action: "setNearLine:", forControlEvents: UIControlEvents.TouchUpInside)
        nearLineLabel.text = "吸附线"
    }
    
    public func setupConstrains(buttons:[UIButton], labels:[UILabel], containerView:UIView) {
        var prevView:UIView?
        for i in 0..<(buttons.count) {
            var button = buttons[i]
            var label = labels[i]
            
            button.setBackgroundImage(UIImage(named: "background_control_selected_phone"), forState: UIControlState.Normal)
            button.setBackgroundImage(UIImage(named: "background_control_normal"), forState: UIControlState.Highlighted)
            button.setBackgroundImage(UIImage(named: "background_control_selecte"), forState: UIControlState.Selected)
            
            containerView.addSubview(button)
            button.snp_remakeConstraints({ (make) -> Void in
                if let view = prevView {
                    make.leading.equalTo(view.snp_trailing).offset(self.padding)
                }else {
                    make.leading.equalTo(containerView)
                }
                make.width.equalTo(self.buttonWidth)
                make.height.equalTo(self.buttonWidth)
                make.top.equalTo(containerView)
                prevView = button
            })
            
            label.font = UIFont.boldSystemFontOfSize(14)
            label.textColor = UIColor.colorWithRGB(0x35bbf0)
            label.textAlignment = NSTextAlignment.Center
            
            containerView.addSubview(label)
            label.snp_remakeConstraints({ (make) -> Void in
                make.centerX.equalTo(button)
                make.top.equalTo(button.snp_bottom)
            })
        }
    }
    
    
    
    public override func getControlPanelHeight()->CGFloat {
        return 60
    }
    
    public override func getControlPanelWidth()->CGFloat {
        var width:CGFloat = CGFloat(buttons.count + 3)*buttonWidth + CGFloat(buttons.count + 2)*padding
        return width
    }
    
    public func cancelSelect(sender:UIButton) {
        sketchGraphicsLayer.cancelSelect()
        self.deselectBtn.enabled = false
        self.removeBtn.enabled = false
    }
    
    public func undo(sender:UIButton) {
        sketchGraphicsLayer.undo()
    }
    
    public func removeCurSelect(sender:UIButton) {
        sketchGraphicsLayer.removeCurSelect()
        self.removeBtn.enabled = false
        self.deselectBtn.enabled = false
    }
    
    public func singleGps(sender:UIButton) {
        isSingleLocating = true
        setAllButtonEnable(false)
        locationUtils.startLocate()
    }
    
    public func coordinateInput(sender:UIButton) {
        var pointInputView = PointInputView(frame: CGRectZero)
        pointInputView.mapView = self.sketchGraphicsLayer.mapView
        
        var alertViewController = SDCAlertController(title: "输入坐标", message: "", preferredStyle: SDCAlertControllerStyle.Alert)
        var cancelAction = SDCAlertAction(title: "取消", style: SDCAlertActionStyle.Cancel) { (alertAction:SDCAlertAction!) -> Void in
            
        }
        
        var finishAction = SDCAlertAction(title: "确定", style: SDCAlertActionStyle.Default) { (alertAction:SDCAlertAction!) -> Void in
            if let point = pointInputView.point {
                if self.sketchGraphicsLayer.mapView.maxEnvelope.containsPoint(point) {
                    self.sketchGraphicsLayer.onPoint(point)
                    self.sketchGraphicsLayer.mapView.centerAtPoint(point, animated: true)
                }else {
                    var alertView = UIAlertView(title: "", message: "超出地图范围", delegate: nil, cancelButtonTitle: "确定")
                    alertView.show()
                }
            }else {
                var alertView = UIAlertView(title: "", message: "输入的必须是数字", delegate: nil, cancelButtonTitle: "确定")
                alertView.show()
            }
        }
        alertViewController.addAction(cancelAction)
        alertViewController.addAction(finishAction)
        
        
        alertViewController.contentView.addSubview(pointInputView)
        pointInputView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(alertViewController.contentView)
        }
        alertViewController.presentWithCompletion { () -> Void in
            
        }
    }
    
    public func startHandDraw(sender:UIButton) {
        sketchGraphicsLayer.handDrawModule?.start()
    }
    
    public func startPathRecord(sender:UIButton) {
        if isPathRecord {
            self.pathRecordBtn.selected = false
            locationUtils.stopLocate()
            setAllButtonEnable(true)
        }else {
            sketchGraphicsLayer.cancelSelect()
            setAllButtonEnable(false)
            self.pathRecordBtn.enabled = true
            self.pathRecordBtn.selected = true
            locationUtils.startLocate()
        }
        isPathRecord = !isPathRecord
    }
    
    public func buffer(sender:UIButton) {
        var bufferModalView:BufferModalView = BufferModalView(frame: CGRectZero)
        bufferModalView.sketchGraphicsLayer = self.sketchGraphicsLayer
        
        var alertViewController = SDCAlertController(title: "缓冲区设置", message: "", preferredStyle: SDCAlertControllerStyle.Alert)
        var cancelAction = SDCAlertAction(title: "取消", style: SDCAlertActionStyle.Cancel, handler: nil)
        
        var finishAction = SDCAlertAction(title: "确定", style: SDCAlertActionStyle.Default) { (alertAction:SDCAlertAction!) -> Void in
            self.sketchGraphicsLayer.isBufferEnable = bufferModalView.bufferEnanleSwitch.on
            self.bufferBtn.selected = self.sketchGraphicsLayer.isBufferEnable
            self.sketchGraphicsLayer.bufferRadius = Double(bufferModalView.radiusSlider.value)
        }
        
        bufferModalView.bufferEnanleSwitch.on = self.sketchGraphicsLayer.isBufferEnable
        bufferModalView.radiusLabel.text = String(format: "%.2f 米", arguments: [self.sketchGraphicsLayer.bufferRadius])
        bufferModalView.radiusSlider.value = Float(self.sketchGraphicsLayer.bufferRadius)
        
        alertViewController.addAction(cancelAction)
        alertViewController.addAction(finishAction)
        
        
        alertViewController.contentView.addSubview(bufferModalView)
        bufferModalView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(alertViewController.contentView)
        }
        alertViewController.presentWithCompletion(nil)
    }
    
    public func mergeAdd(sender:UIButton) {
        sketchGraphicsLayer.mergeAdd()
    }
    
    public func mergeSubtract(sender:UIButton) {
        sketchGraphicsLayer.mergeSubtract()
    }
    
    public func handDrawComplete(sender:UIButton) {
        sketchGraphicsLayer.handDrawModule?.complete()
    }
    
    public func handDrawCancel(sender:UIButton) {
        sketchGraphicsLayer.handDrawModule?.stop()
    }
    
    public func handDrawClear(sender:UIButton) {
        sketchGraphicsLayer.handDrawModule?.clear()
    }
    
    public func geometryCut(sender:UIButton) {
        setCutStart(!sender.selected)
    }
    
    private func setCutStart(start:Bool) {
        if let acquisitionCutManager = self.acquisitionCutManager {
            acquisitionCutManager.cutCallback = self
            if start {
                acquisitionCutManager.start(sketchGraphicsLayer.getGeometry())
                setAllButtonEnable(false)
                self.cutBtn.enabled = true
                self.cutBtn.selected = true
            }else {
                acquisitionCutManager.stop()
                setAllButtonEnable(true)
                 self.cutBtn.selected = false
            }
        }
    }
    
    public var cutCallback:CutManagerCallback?
    
    public func onCut(geometry1: AGSGeometry, geometry2: AGSGeometry) {
        var alertViewController = SDCAlertController(title: "分割", message: "确定分割?", preferredStyle: SDCAlertControllerStyle.Alert)
        var cancelAction = SDCAlertAction(title: "取消", style: SDCAlertActionStyle.Cancel) { (alertAction:SDCAlertAction!) -> Void in
            self.setCutStart(false)
        }
        
        var finishAction = SDCAlertAction(title: "确定", style: SDCAlertActionStyle.Default) { (alertAction:SDCAlertAction!) -> Void in
            self.setCutStart(false)
            if self.cutCallback != nil {
                self.sketchGraphicsLayer.setGeometry(geometry1)
                self.cutCallback?.onCut(geometry1, geometry2: geometry2)
            }
        }
        
        alertViewController.addAction(cancelAction)
        alertViewController.addAction(finishAction)
        
        alertViewController.presentWithCompletion(nil)
    }
    
    public func setMergeStart(start:Bool) {
        if let mergeManager = self.acquisitionMergeManager {
            if start {
                mergeManager.start(sketchGraphicsLayer.getGeometry())
                setAllButtonEnable(false)
                self.mergeBtn.enabled = true
                self.mergeBtn.selected = true
            } else {
                mergeManager.finish()
                setAllButtonEnable(true)
                self.mergeBtn.selected = false
            }
        }
    }
    
    public func geometryMerge(sender:UIButton) {
        setMergeStart(!sender.selected)
    }
    
    public func setNearLine(sender:UIButton) {
        sender.selected = !sender.selected
    }
    
    public override func showHandDrawPanel(show: Bool) {
        if show {
            handDrawBtnContainer.hidden = false
            btnContainer.hidden = true
            controlPanelView?.bringSubviewToFront(btnContainer)
        }else {
            handDrawBtnContainer.hidden = true
            btnContainer.hidden = false
            controlPanelView?.bringSubviewToFront(handDrawBtnContainer)
        }
        
    }
    
    public func setAllButtonEnable(enable:Bool) {
        for button in self.buttons {
            button.enabled = enable
        }
    }
    
    public func locationUtils(utils: LocationUtils!, didUpdateToPoint point: AGSPoint!) {
        if isSingleLocating {
            setAllButtonEnable(true)
            isSingleLocating = false
            
            if point == nil {
                var alertView = UIAlertView(title: "", message: "定位失败", delegate: nil, cancelButtonTitle: "确定")
                alertView.show()
            }else {
                sketchGraphicsLayer.onPoint(point)
                sketchGraphicsLayer.mapView.centerAtPoint(point, animated: true)
            }
            
            utils.stopLocate()
        }
        
        if isPathRecord {
            if point != nil {
                sketchGraphicsLayer.onPoint(point)
            }
        }
    }
}

class PointInputView:UIView {
    var xValueTextField:UITextField = UITextField(frame: CGRectZero)
    
    var yValueTextField:UITextField = UITextField(frame: CGRectZero)
    
    var padding = 5
    
    var mapView:AGSMapView? {
        didSet {
            if let point = self.mapView?.visibleAreaEnvelope.center {
                xValueTextField.text = "\(point.x)"
                yValueTextField.text = "\(point.y)"
            }
        }
    }
    
    var point:AGSPoint? {
        if let spatialReference = self.mapView?.spatialReference {
            if isNumber(xValueTextField.text) && isNumber(yValueTextField.text){
                var formatter = NSNumberFormatter()
                var xValue = formatter.numberFromString(xValueTextField.text)!.doubleValue
                var yValue = formatter.numberFromString(yValueTextField.text)!.doubleValue
                return AGSPoint(x: xValue, y: yValue, spatialReference: spatialReference)
            }
        }
        return nil
    }
    
    func isNumber(str:String)->Bool {
        var isInt = isPureInt(str)
        var isDecimal = isPureDecimal(str)
        return isInt || isDecimal
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPointInputView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPointInputView()
    }
    
    func setupPointInputView() {
        xValueTextField.placeholder = "X 坐标"
        yValueTextField.placeholder = "Y 坐标"
        
        xValueTextField.borderStyle = UITextBorderStyle.RoundedRect
        xValueTextField.font = UIFont.systemFontOfSize(12)
        xValueTextField.keyboardType = UIKeyboardType.DecimalPad
        
        yValueTextField.borderStyle = UITextBorderStyle.RoundedRect
        yValueTextField.font = UIFont.systemFontOfSize(12)
        yValueTextField.keyboardType = UIKeyboardType.DecimalPad
        
        self.addSubview(xValueTextField)
        self.addSubview(yValueTextField)
        
        xValueTextField.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self).offset(self.padding)
            make.trailing.equalTo(self).offset(-self.padding)
            make.top.equalTo(self)
            make.height.equalTo(40)
        }
        
        yValueTextField.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self).offset(self.padding)
            make.trailing.equalTo(self).offset(-self.padding)
            make.top.equalTo(self.xValueTextField.snp_bottom).offset(self.padding)
            make.height.equalTo(40)
            make.bottom.equalTo(self).offset(-self.padding)
        }
    }
    
    func isPureInt(string:String)->Bool {
        var scan = NSScanner(string: string)
        var intValue:Int = 0
        return scan.scanInteger(&intValue) && scan.atEnd
    }
    
    func isPureDecimal(string:String)->Bool {
        var scan = NSScanner(string: string)
        var floatValue: Float = 0
        return scan.scanFloat(&floatValue) && scan.atEnd
    }

}


class BufferModalView: UIView {
    //MARK:Properties
    var bufferEnanleSwitch:UISwitch = UISwitch(frame: CGRectZero)
    
    var radiusSlider:UISlider = UISlider(frame: CGRectZero)
    
    var radiusLabel:UILabel = UILabel(frame: CGRectZero)
    
    var sketchGraphicsLayer:SketchGraphicsLayer?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customView()
    }
    
    private func customView(){
        addSubview(bufferEnanleSwitch)
        addSubview(radiusSlider)
        addSubview(radiusLabel)
        
        
        if let layer = sketchGraphicsLayer {
            bufferEnanleSwitch.on = layer.isBufferEnable
        }
        
        radiusSlider.maximumValue = 10000
        radiusSlider.value = 0
        radiusSlider.addTarget(self, action: "bufferRaiudsChanges:", forControlEvents: UIControlEvents.ValueChanged)
        
        radiusLabel.text = "0 米"
        radiusLabel.font = UIFont.systemFontOfSize(14)
        
        setupConstraints()
    }
    
    func bufferRaiudsChanges(sender:UISlider) {
        radiusLabel.text = "\(sender.value) 米"
    }
    
    func setupConstraints() {
        bufferEnanleSwitch.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self).offset(5)
            make.top.equalTo(self).offset(5)
        }
        
        radiusLabel.snp_makeConstraints { (make) -> Void in
            make.trailing.equalTo(self).offset(-5)
            make.centerY.equalTo(self.bufferEnanleSwitch)
        }
        
        radiusSlider.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self).offset(5)
            make.trailing.equalTo(self).offset(-5)
            make.top.equalTo(self.bufferEnanleSwitch.snp_bottom).offset(10)
            make.bottom.equalTo(self).offset(-20)
        }
    }
}
