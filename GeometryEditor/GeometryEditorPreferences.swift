//
//  GeometryEditorPreferences.swift
//  GeometryEditor
//
//  Created by damingdan on 15/5/18.
//  Copyright (c) 2015年 kingoit. All rights reserved.
//

import UIKit

public class GeometryEditorPreferences: NSObject {
    private static let NEAR_RADIUS_KEY = "NEAR_RADIUS_KEY"
    
    public static let DEF_NEAR_RADIUS:Int = 40
    
    private static var nearRadius:Int = -1
    
    private static var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    public static func setNearRadius(radius:Int) {
        if nearRadius == radius {
            return
        }
        nearRadius = radius
        if nearRadius < 20  {
            nearRadius = 20
        }else if nearRadius > 150 {
            nearRadius = 150
        }
        
        userDefaults.setInteger(nearRadius, forKey: NEAR_RADIUS_KEY)
    }
    
    public static func getNearRadius()->Int {
        if nearRadius < 0 {
            nearRadius = userDefaults.integerForKey(NEAR_RADIUS_KEY)
            if nearRadius == 0 {
                nearRadius = DEF_NEAR_RADIUS
            }
        }
        return nearRadius
    }
}
