//
//  CircleGraphView.swift
//  2nLine
//
//  Created by Alexey Yurko on 25.04.16.
//  Copyright © 2016 Alexey Yurko. All rights reserved.
//

import UIKit

class CircleGraphView: UIView {
    
    var endArc:CGFloat = 0.0{   // in range of 0.0 to 1.0
        didSet{
            setNeedsDisplay()
        }
    }
    
    var arcWidth:CGFloat = 8.0
    var arcColor = UIColor.darkGrayColor()
    var arcBackgroundColor = UIColor.darkGrayColor()
    var isPie: Bool = false
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        //Important constants for circle
        let fullCircle = 2.0 * CGFloat(M_PI)
        let start:CGFloat = -0.25 * fullCircle
        let end:CGFloat = endArc * fullCircle + start
        
        
        //find the centerpoint of the rect
        let centerPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
        
        //define the radius by the smallest side of the view
        var radius:CGFloat = 0.0
        if CGRectGetWidth(rect) > CGRectGetHeight(rect){
            radius = (CGRectGetWidth(rect) - arcWidth) / 2.0 * 0.85
        } else {
            radius = (CGRectGetHeight(rect) - arcWidth) / 2.0 * 0.85
        }
        
        //starting point for all drawing code is getting the context.
        let context = UIGraphicsGetCurrentContext()
        
        //set colorspace
        //     let colorspace = CGColorSpaceCreateDeviceRGB()
        
        //set line attributes
        CGContextSetLineWidth(context, arcWidth)
        CGContextSetLineCap(context, .Round)
        CGContextSetStrokeColorWithColor(context, arcColor.CGColor)
        
        if isPie {
            CGContextSetFillColorWithColor(context, arcColor.CGColor)
            CGContextMoveToPoint(context, centerPoint.x, centerPoint.y)
            CGContextAddArc(context, centerPoint.x, centerPoint.y, radius, start, end, 0)
            
            CGContextSetShadowWithColor(context, CGSizeMake(3, 3), 2, UIColor.grayColor().CGColor)
            
            CGContextFillPath(context)
        }   else {
            CGContextSetStrokeColorWithColor(context, arcColor.CGColor)
            CGContextSetLineWidth(context, arcWidth * 0.8 )
            CGContextAddArc(context, centerPoint.x, centerPoint.y, radius, start, end, 0)
            
            CGContextSetShadowWithColor(context, CGSizeMake(3, 3), 2, UIColor.grayColor().CGColor)
            
            CGContextStrokePath(context)
        }
        
    }
    
}
