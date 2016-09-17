//
//  RBBSpringAnimation.h
//  RBBAnimation
//
//  Created by Robert Böhnke on 10/14/13.
//  Copyright (c) 2013 Robert Böhnke. All rights reserved.
//

//
//  RBBSpringAnimation.swift
//
//  Swift intepretation of the Objective-C original by Marin Todorov
//  Copyright (c) 2015-2016 Underplot ltd. All rights reserved.
//

import UIKit

class RBBSpringAnimation: CAKeyframeAnimation {
    
    var damping: Double = 0.01
    var velocity: Double = 0.0
    
    var from: Any?
    var to: Any?
    
    var allowsOverdamping: Bool = true
    
    typealias RBBAnimationBlock = (CGFloat, CGFloat) -> Any //(t, duration)
    
    var mass: Double = 1.0
    var stiffness: Double = 0.0
    
    private func durationForEpsilon(_ epsilon: Double) -> CFTimeInterval {
        let beta = damping / (2 * mass)
        var duration: CFTimeInterval = 0
    
        while (exp(-beta * duration) >= epsilon) {
            duration += 0.1
        }
        
        return duration
    }
    
    private lazy var blockArrayValues: RBBBlockBasedArray = {
        var result = RBBBlockBasedArray()
        let block: RBBBlockBasedArrayBlock = {index in
            return self.animationBlock(CGFloat(index) / 60.0, CGFloat(self.duration))
        }
        result.setCount(Int(self.duration * 60), block: block)
        return result
    }()
    
    override var values: [Any]! {
        get {
            return blockArrayValues.asAnys()
        }
        set {
            //no storage for this property
        }
    }
    
    override init() {
        super.init()
        
        damping = 10
        mass = 1
        stiffness = 100
        
        calculationMode = kCAAnimationDiscrete
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: RBBAnimation
    private var animationBlock: RBBAnimationBlock {
        
        let b = CGFloat(damping)
        let m = CGFloat(mass)
        let k = CGFloat(stiffness)
        let v0 = CGFloat(velocity)
        
        if b <= 0.0 || k <= 0.0 || b <= 0.0 {
            fatalError("Incorrect animation values")
        }
        
        var beta: CGFloat = b / (2 * m)
        let omega0: CGFloat = sqrt(k / m)
        let omega1: CGFloat = sqrt((omega0 * omega0) - (beta * beta))
        let omega2: CGFloat = sqrt((beta * beta) - (omega0 * omega0))
        
        let x0: CGFloat = -1

        if allowsOverdamping && beta > omega0 {
            beta = omega0
        }
        
        var oscillation: (CGFloat)->CGFloat
        
        if beta < omega0 {
            // Underdamped
            oscillation = {t in
                let envelope: CGFloat = exp(-beta * t)
                
                let part2: CGFloat = x0 * cos(omega1 * t)
                let part3: CGFloat = ((beta * x0 + v0) / omega1) * sin(omega1 * t)
                return -x0 + envelope * (part2 + part3)
            };
        } else if beta == omega0 {
            // Critically damped
            oscillation = {t in
                let envelope: CGFloat = exp(-beta * t)
                return -x0 + envelope * (x0 + (beta * x0 + v0) * t)
            };
        } else {
            // Overdamped
            oscillation = {t in
                let envelope: CGFloat = exp(-beta * t)
                let part2: CGFloat = x0 * cosh(omega2 * t)
                let part3: CGFloat = ((beta * x0 + v0) / omega2) * sinh(omega2 * t)
                return -x0 + envelope * (part2 + part3);
            };
        }

        let lerp = RBBInterpolator.interpolate(self.from!, to: self.to!)
        let result: RBBAnimationBlock = {t, _ in
            return lerp(oscillation(t))
        }
        return result
    }


    override func copy(with zone: NSZone?) -> Any {
        let anim = super.copy(with: zone) as! RBBSpringAnimation

        anim.damping = self.damping
        anim.velocity = self.velocity
        anim.duration = self.duration
        
        anim.from = self.from
        anim.to = self.to
        
        anim.mass = self.mass
        anim.stiffness = self.stiffness
        
        anim.allowsOverdamping = self.allowsOverdamping
        
        return anim
    }
}
