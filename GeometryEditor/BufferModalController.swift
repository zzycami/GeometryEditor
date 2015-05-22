//
//  BufferModalController.swift
//  GeometryEditorExampleSwift
//
//  Created by damingdan on 15/5/22.
//  Copyright (c) 2015年 kingoit. All rights reserved.
//

import UIKit

class BufferModalController: UIViewController {
    //MARK:Properties
    var bufferEnanleSwitch:UISwitch = UISwitch(frame: CGRectZero)
    
    var radiusSlider:UISlider = UISlider(frame: CGRectZero)
    
    var radiusLabel:UILabel = UILabel(frame: CGRectZero)
    
    var sketchGraphicsLayer:SketchGraphicsLayer?
    
    //MARK:Lift Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customView()
        self.view.addSubview(bufferEnanleSwitch)
        self.view.addSubview(radiusSlider)
        self.view.addSubview(radiusLabel)
        layoutSubviews()
    }
    
    private func customView(){
        if let layer = sketchGraphicsLayer {
            bufferEnanleSwitch.on = layer.isBufferEnable
        }
        
        radiusSlider.maximumValue = 10000
        radiusSlider.value = 0
        
        radiusLabel.text = "0 米"
    }
    
    private func layoutSubviews() {
        bufferEnanleSwitch.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self.view).offset(5)
            make.top.equalTo(self.view).offset(5)
        }
        
        radiusLabel.snp_makeConstraints { (make) -> Void in
            make.trailing.equalTo(self.view).offset(-5)
            make.top.equalTo(self.view).offset(5)
        }
        
        radiusSlider.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self.view)
            make.trailing.equalTo(self.view)
            make.top.equalTo(self.bufferEnanleSwitch).offset(10)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
}
