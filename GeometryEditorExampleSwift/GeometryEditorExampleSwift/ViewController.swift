//
//  ViewController.swift
//  GeometryEditorExampleSwift
//
//  Created by damingdan on 15/5/21.
//  Copyright (c) 2015年 kingoit. All rights reserved.
//

import UIKit
import ArcGIS

class ViewController: UIViewController, AGSMapViewLayerDelegate, AGSLayerDelegate {

    @IBOutlet weak var mapView: AGSMapView!
    
    var sketchGraphicsLayer:SketchGraphicsLayer!
    
    //@IBOutlet weak var canvasView: CanvasView!
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        mapView.layerDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onEditPressed(sender: UIBarButtonItem) {
        if sketchGraphicsLayer.isStart {
            sender.title = "开始图形编辑"
            sketchGraphicsLayer.stop()
        }else {
            sender.title = "停止图形编辑"
            sketchGraphicsLayer.start()
        }
    }

    
    //MARK:Private Method
    func setupMapView() {
        var url = NSURL(string: "http://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer")
        var mapLayer = AGSTiledMapServiceLayer(URL: url)
        mapLayer.delegate = self
        mapView.addMapLayer(mapLayer, withName: "Tiled Layer")
        
        sketchGraphicsLayer = SketchGraphicsLayer()
        mapView.addMapLayer(sketchGraphicsLayer, withName: "Sketch layer")
        mapView.touchDelegate = sketchGraphicsLayer
    }
    
}

