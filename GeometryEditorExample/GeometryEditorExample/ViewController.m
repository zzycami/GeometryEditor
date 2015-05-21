//
//  ViewController.m
//  GeometryEditorExample
//
//  Created by damingdan on 15/5/18.
//  Copyright (c) 2015年 kingoit. All rights reserved.
//

#import "ViewController.h"
#import <ArcGIS/ArcGIS.h>
#import "GeometryEditorExample-swift.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet AGSMapView *mapView;
@property (retain, nonatomic) SketchGraphicsLayer* sketchGraphicLayer;
@end

@implementation ViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMapView];
    [self.mapView addMapLayer:self.sketchGraphicLayer withName:@"Sketch layer"];
    self.mapView.touchDelegate = self.sketchGraphicLayer;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
- (void) setupMapView {
    NSURL* url = [[NSURL alloc] initWithString:@"http://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer"];
    AGSTiledMapServiceLayer* mapLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:url];
    [self.mapView addMapLayer:mapLayer withName:@"Tiled Layer"];
}


#pragma mark Setter & Getter
- (SketchGraphicsLayer*) sketchGraphicLayer {
    if (!_sketchGraphicLayer) {
        _sketchGraphicLayer = [[SketchGraphicsLayer alloc] initWithSpatialReference:self.mapView.spatialReference];
    }
    return _sketchGraphicLayer;
}

@end
