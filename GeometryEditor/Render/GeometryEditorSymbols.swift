//
//  GeometryEditorValues.swift
//  GeometryEditor
//
//  Created by damingdan on 15/5/20.
//  Copyright (c) 2015年 kingoit. All rights reserved.
//

import UIKit
import ArcGIS

extension UIColor {
    class func colorWithRGB(value:Int)->UIColor {
        var redValue = CGFloat(value & 0xFF0000 >> 16)/255.0;
        var greenValue = CGFloat(value & 0x00FF00 >> 8)/255.0;
        var blueValue = CGFloat(value & 0x0000FF)/255.0;
        return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1);
    }
}

class GeometryEditorSymbols: NSObject {
    static let NonActivePolylineSymbol:AGSSimpleLineSymbol = AGSSimpleLineSymbol(color: UIColor.colorWithRGB(0xFF6A6A), width: 1.7)
    
    static var NonActivePolygonSymbol:AGSSimpleFillSymbol {
        get {
            var symbol = AGSSimpleFillSymbol(color: UIColor.colorWithRGB(0x00E5EE), outlineColor: UIColor.grayColor())
            symbol.outline = NonActivePolylineSymbol
            symbol.style = AGSSimpleFillSymbolStyle.DiagonalCross
            return symbol
        }
    }
    
    static let ActivePolylineSymbol:AGSSimpleLineSymbol = AGSSimpleLineSymbol(color: UIColor.colorWithRGB(0xFF6A6A), width: 1.7)
    
    static var ActivePolygonSymbol:AGSSimpleFillSymbol {
        get {
            var symbol = AGSSimpleFillSymbol(color: UIColor.colorWithRGB(0x00E5EE), outlineColor: UIColor.grayColor())
            symbol.outline = ActivePolylineSymbol
            symbol.style = AGSSimpleFillSymbolStyle.Cross
            return symbol
        }
    }
    
    static var NormalPointSymbol:AGSSimpleMarkerSymbol{
        get {
            var symbol = AGSSimpleMarkerSymbol(color: UIColor.colorWithRGB(0x00CCFF))
            symbol.style = AGSSimpleMarkerSymbolStyle.Circle
            symbol.size = CGSizeMake(7, 7)
            return symbol
        }
    }
    
    static var MidPointSymbol:AGSSimpleMarkerSymbol {
        get {
            var symbol = AGSSimpleMarkerSymbol(color: UIColor.greenColor())
            symbol.size = CGSizeMake(6, 6)
            symbol.style = AGSSimpleMarkerSymbolStyle.Diamond
            return symbol
        }
    }
    
    static var StartPointSymbol:AGSSimpleMarkerSymbol {
        get {
            var symbol = AGSSimpleMarkerSymbol(color: UIColor.greenColor())
            symbol.size = CGSizeMake(10, 10)
            symbol.style = AGSSimpleMarkerSymbolStyle.Cross
            return symbol
        }
    }
    
    static var EndPointSymbol:AGSSimpleMarkerSymbol {
        get {
            var symbol = AGSSimpleMarkerSymbol(color: UIColor.colorWithRGB(0x9400D3))
            symbol.size = CGSizeMake(10, 10)
            symbol.style = AGSSimpleMarkerSymbolStyle.Circle
            return symbol
        }
    }
    
    static var SelectionSymbol:AGSSimpleMarkerSymbol {
        get {
            var symbol = AGSSimpleMarkerSymbol(color: UIColor.colorWithRGB(0x00FF7F))
            symbol.style = AGSSimpleMarkerSymbolStyle.Circle
            symbol.size = CGSizeMake(10, 10)
            return symbol
        }
    }
    
    private static var BufferSymbol:AGSSimpleLineSymbol {
        get {
            var symbol = AGSSimpleLineSymbol(color: UIColor.greenColor(), width: 1.7)
            symbol.style = AGSSimpleLineSymbolStyle.DashDot
            return symbol
        }
    }
    
    static let AttributeField = "F"
    
    static let NonActivePolylineValue = "1"
    static let NonActivePolygonValue = "2"
    static let ActivePolylineValue = "3"
    static let ActivePolygonValue = "4"
    static let NormalPointValue = "5"
    static let MidPointValue = "6"
    static let StartPointValue = "7"
    static let EndPointValue = "8"
    static let SelectionValue = "9"
    static let BufferValue = "10"
    
    
    static let NonActivePolylineAttr = [AttributeField : NonActivePolylineValue]
    static let NonActivePolygonAttr = [AttributeField : NonActivePolygonValue]
    static let ActivePolylineAttr = [AttributeField : ActivePolylineValue]
    static let ActivePolygonAttr = [AttributeField : ActivePolygonValue]
    static let NormalPointAttr = [AttributeField : NormalPointValue]
    static let MidPointAttr = [AttributeField : MidPointValue]
    static let StartPointAttr = [AttributeField : StartPointValue]
    static let EndPointAttr = [AttributeField : EndPointValue]
    static let SelectionAttr = [AttributeField : SelectionValue]
    static let BufferAttr = [AttributeField : BufferValue]
    
    static func createRender()->AGSRenderer {
        var values = [NonActivePolylineValue, NonActivePolygonValue, ActivePolylineValue, ActivePolygonValue, NormalPointValue, MidPointValue, StartPointValue, EndPointValue, SelectionValue, BufferValue]
        
        var symbols = [NonActivePolylineSymbol, NonActivePolygonSymbol, ActivePolylineSymbol, ActivePolygonSymbol, NormalPointSymbol, MidPointSymbol, StartPointSymbol, EndPointSymbol, SelectionSymbol, BufferSymbol]
        
        var render = AGSUniqueValueRenderer()
        render.fields = [AttributeField]
        
        for i in 0..<values.count {
            var value = AGSUniqueValue(value: values[i], label: "", description: "", symbol: symbols[i])
            render.uniqueValues.append(value)
        }
        
        return render
    }
    
}