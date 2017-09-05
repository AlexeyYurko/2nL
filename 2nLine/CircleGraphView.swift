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
    var arcColor = UIColor.darkGray
    var arcBackgroundColor = UIColor.darkGray
    var isPie: Bool = false
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        //Important constants for circle
        let fullCircle = 2.0 * CGFloat(M_PI)
        let start:CGFloat = -0.25 * fullCircle
        let end:CGFloat = endArc * fullCircle + start
        
        
        //find the centerpoint of the rect
        let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
        
        //define the radius by the smallest side of the view
        var radius:CGFloat = 0.0
        if rect.width > rect.height{
            radius = (rect.width - arcWidth) / 2.0 * 0.85
        } else {
            radius = (rect.height - arcWidth) / 2.0 * 0.85
        }
        
        //starting point for all drawing code is getting the context.
        let context = UIGraphicsGetCurrentContext()
        
        //set colorspace
        //     let colorspace = CGColorSpaceCreateDeviceRGB()
        
        //set line attributes
        context?.setLineWidth(arcWidth)
        context?.setLineCap(.round)
        context?.setStrokeColor(arcColor.cgColor)
        
        if isPie {
            context?.setFillColor(arcColor.cgColor)
            context?.move(to: CGPoint(x: centerPoint.x, y: centerPoint.y))
            context?.addArc(center:CGPoint(x: centerPoint.x, y: centerPoint.y), radius: radius, startAngle: start, endAngle: end, clockwise: false)
            
            context?.setShadow(offset: CGSize(width: 3, height: 3), blur: 2, color: UIColor.gray.cgColor)
            
            context?.fillPath()
        }   else {
            context?.setStrokeColor(arcColor.cgColor)
            context?.setLineWidth(arcWidth * 0.8 )
            context?.addArc(center:CGPoint(x: centerPoint.x, y: centerPoint.y), radius: radius, startAngle: start, endAngle: end, clockwise: false)
            
            context?.setShadow(offset: CGSize(width: 3, height: 3), blur: 2, color: UIColor.gray.cgColor)
            
            context?.strokePath()
        }
        
    }
    
}
