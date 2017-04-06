//
//  RBBLinearInterpolation.h
//  RBBAnimation
//
//  Created by Robert Böhnke on 10/25/13.
//  Copyright (c) 2013 Robert Böhnke. All rights reserved.
//

//
//  RBBLinearInterpolation.swift
//
//  Swift intepretation of the Objective-C original by Marin Todorov
//  Copyright (c) 2015-2016 Underplot ltd. All rights reserved.
//

import UIKit

typealias RBBLinearInterpolation = (_ fraction: CGFloat) -> Any

class RBBInterpolator
{
    // MARK: public interpolation methods
    static func interpolate(_ from: Any, to: Any) -> RBBLinearInterpolation
    {
        //Int
        if let from = from as? Int, let to = to as? Int {
            return self.RBBInterpolateCGFloat(CGFloat(from), to: CGFloat(to))
        }

        //Double
        if let from = from as? Double, let to = to as? Double {
            return self.RBBInterpolateCGFloat(CGFloat(from), to: CGFloat(to))
        }
        
        //CGFloat
        if let from = from as? CGFloat, let to = to as? CGFloat {
            return self.RBBInterpolateCGFloat(from, to: to)
        }

        //UIColor
        if let from = from as? UIColor, let to = to as? UIColor {
            return self.RBBInterpolateUIColor(from, to: to)
        }
        
        //CGColorRef
        
        //NSValue
        if let from = from as? NSValue, let to = to as? NSValue {
            let type = String(cString: from.objCType) //should check to's type too?

            //CGPoint
            if type.hasPrefix("{CGPoint") {
                return self.RBBInterpolateCGPoint(from.cgPointValue, to: to.cgPointValue)
            }
            //CGSize
            if type.hasPrefix("{CGSize") {
                return self.RBBInterpolateCGSize(from.cgSizeValue, to: to.cgSizeValue)
            }
            //CGRect
            if type.hasPrefix("{CGRect") {
                return self.RBBInterpolateCGRect(from.cgRectValue, to: to.cgRectValue)
            }
            //CATransform3D
            if type.hasPrefix("{CATransform3D") {
                return self.RBBInterpolateCATransform3D(from.caTransform3DValue, to: to.caTransform3DValue)
            }
        }
        
        //other type?
        let _: RBBLinearInterpolation = {fraction in
            return ((fraction < 0.5) ? from : to) as AnyObject
        }

        //core foundation
        let fromRefType = CFGetTypeID(from as CFTypeRef)
        let toRefType = CFGetTypeID(to as CFTypeRef)

        if fromRefType == CGColor.typeID && toRefType == CGColor.typeID {
            //CGColor
            let fromCGColor = from as! CGColor
            let toCGColor = to as! CGColor
            
            return self.RBBInterpolateUIColor(UIColor(cgColor: fromCGColor), to: UIColor(cgColor: toCGColor))
        }
        
        fatalError("Unknown type of animated property")
    }
    
    // MARK: private interpolation methods
    private static func RBBInterpolateCATransform3D(_ from: CATransform3D, to: CATransform3D) -> RBBLinearInterpolation
    {
        let delta = CATransform3D(
            m11: to.m11 - from.m11,
            m12: to.m12 - from.m12,
            m13: to.m13 - from.m13,
            m14: to.m14 - from.m14,
            m21: to.m21 - from.m21,
            m22: to.m22 - from.m22,
            m23: to.m23 - from.m23,
            m24: to.m24 - from.m24,
            m31: to.m31 - from.m31,
            m32: to.m32 - from.m32,
            m33: to.m33 - from.m33,
            m34: to.m34 - from.m34,
            m41: to.m41 - from.m41,
            m42: to.m42 - from.m42,
            m43: to.m43 - from.m43,
            m44: to.m44 - from.m44
        )
        
        let result: RBBLinearInterpolation = {fraction in
            let transform = CATransform3D(
                m11: from.m11 + fraction * delta.m11,
                m12: from.m12 + fraction * delta.m12,
                m13: from.m13 + fraction * delta.m13,
                m14: from.m14 + fraction * delta.m14,
                m21: from.m21 + fraction * delta.m21,
                m22: from.m22 + fraction * delta.m22,
                m23: from.m23 + fraction * delta.m23,
                m24: from.m24 + fraction * delta.m24,
                m31: from.m31 + fraction * delta.m31,
                m32: from.m32 + fraction * delta.m32,
                m33: from.m33 + fraction * delta.m33,
                m34: from.m34 + fraction * delta.m34,
                m41: from.m41 + fraction * delta.m41,
                m42: from.m42 + fraction * delta.m42,
                m43: from.m43 + fraction * delta.m43,
                m44: from.m44 + fraction * delta.m44)
            
            return NSValue(caTransform3D: transform)
        }
        
        return result
    }
    
    private static func RBBInterpolateCGRect(_ from: CGRect, to: CGRect) -> RBBLinearInterpolation
    {
        let deltaX = to.origin.x - from.origin.x
        let deltaY = to.origin.y - from.origin.y
        let deltaWidth = to.size.width - from.size.width
        let deltaHeight = to.size.height - from.size.height
        
        let result: RBBLinearInterpolation = {fraction in
            let rect = CGRect(
                x: from.origin.x + fraction * deltaX,
                y: from.origin.y + fraction * deltaY,
                width: from.size.width + fraction * deltaWidth,
                height: from.size.height + fraction * deltaHeight)
            
            return NSValue(cgRect: rect)
        }
        
        return result
    }
    
    private static func RBBInterpolateCGPoint(_ from: CGPoint, to: CGPoint) -> RBBLinearInterpolation
    {
        let deltaX = to.x - from.x
        let deltaY = to.y - from.y
        
        let result: RBBLinearInterpolation = {fraction in
            let point = CGPoint(
                x: from.x + fraction * deltaX,
                y: from.y + fraction * deltaY
            )
            
            return NSValue(cgPoint: point)
        }
        
        return result
    }
    
    private static func RBBInterpolateCGSize(_ from: CGSize, to: CGSize) -> RBBLinearInterpolation
    {
        let deltaWidth = to.width - from.width
        let deltaHeight = to.height - from.height
        
        let result: RBBLinearInterpolation = {fraction in
            let size = CGSize(
                width: from.width + fraction * deltaWidth,
                height: from.height + fraction * deltaHeight
            )
            
            return NSValue(cgSize: size)
        }
        
        return result
    }
    
    private static func RBBInterpolateCGFloat(_ from: CGFloat, to: CGFloat) -> RBBLinearInterpolation
    {
        let delta = to - from
        
        let result: RBBLinearInterpolation = {fraction in
            return (from + fraction * delta) as AnyObject
        }
        
        return result
    }
    
    private static func RBBInterpolateUIColor(_ from: UIColor, to: UIColor) -> RBBLinearInterpolation
    {
        var fromHue: CGFloat = 0.0
        var fromSaturation: CGFloat = 0.0
        var fromBrightness: CGFloat = 0.0
        var fromAlpha: CGFloat = 0.0
        
        from.getHue(&fromHue, saturation: &fromSaturation, brightness: &fromBrightness, alpha: &fromAlpha)
        
        var toHue: CGFloat = 0.0
        var toSaturation: CGFloat = 0.0
        var toBrightness: CGFloat = 0.0
        var toAlpha: CGFloat = 0.0
        
        to.getHue(&toHue, saturation: &toSaturation, brightness: &toBrightness, alpha: &toAlpha)
        
        let deltaHue = toHue - fromHue
        let deltaSaturation = toSaturation - fromSaturation
        let deltaBrightness = toBrightness - fromBrightness
        let deltaAlpha = toAlpha - fromAlpha
        
        let result: RBBLinearInterpolation = {fraction in
            let hue: CGFloat = fromHue + fraction * deltaHue
            let saturation: CGFloat = fromSaturation + fraction * deltaSaturation
            let brightness: CGFloat = fromBrightness + fraction * deltaBrightness
            let alpha: CGFloat = fromAlpha + fraction * deltaAlpha
            
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha).cgColor
        }
        
        return result
    }
}
