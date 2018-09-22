//
//  EasyAnimation.swift
//
//  Created by Marin Todorov on 4/11/15.
//  Copyright (c) 2015-present Underplot ltd. All rights reserved.
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import ObjectiveC

// MARK: EA private structures

private struct PendingAnimation {
    let layer: CALayer
    let keyPath: String
    let fromValue: Any
}

private class AnimationContext {
    var duration: TimeInterval = 1.0
    var currentTime: TimeInterval = {CACurrentMediaTime()}()
    var delay: TimeInterval = 0.0
    var options: UIView.AnimationOptions? = nil
    var pendingAnimations = [PendingAnimation]()
    
    //spring additions
    var springDamping: CGFloat = 0.0
    var springVelocity: CGFloat = 0.0
    
    var nrOfUIKitAnimations: Int = 0
}

private class CompletionBlock {
    var context: AnimationContext
    var completion: ((Bool) -> Void)
    var nrOfExecutions: Int = 0
    
    init(context c: AnimationContext, completion cb: @escaping (Bool) -> Void) {
        context = c
        completion = cb
    }
    
    func wrapCompletion(_ completed: Bool) {
        // if no uikit animations uikit calls completion immediately
        nrOfExecutions+=1
        
        if context.nrOfUIKitAnimations > 0 ||
            
            //if no layer animations DO call completion
            context.pendingAnimations.count == 0 ||
            
            //skip every other call if no uikit and there are layer animations
            //(e.g. jump over the first immediate uikit call to completion)
            nrOfExecutions % 2 == 0 {
            
                completion(completed)
        }
    }
}

@objc public class EasyAnimation: NSObject {
    static fileprivate var activeAnimationContexts = [AnimationContext]()

    @discardableResult
    override init() { }

    public static func enable() {
        _ = swizzle
    }

    static private let swizzle: Void = {
        UIView.replaceAnimationMethods()
        CALayer.replaceAnimationMethods()
    }()
}

// MARK: EA animatable properties

private let vanillaLayerKeys = [
    "anchorPoint", "backgroundColor", "borderColor", "borderWidth", "bounds",
    "contentsRect", "cornerRadius",
    "opacity", "position",
    "shadowColor", "shadowOffset", "shadowOpacity", "shadowRadius",
    "sublayerTransform", "transform", "zPosition"
]

private let specializedLayerKeys: [String: [String]] = [
    CAEmitterLayer.self.description(): ["emitterPosition", "emitterZPosition", "emitterSize", "spin", "velocity", "birthRate", "lifetime"],
    CAGradientLayer.self.description(): ["colors", "locations", "endPoint", "startPoint"],
    CAReplicatorLayer.self.description(): ["instanceDelay", "instanceTransform", "instanceColor", "instanceRedOffset", "instanceGreenOffset", "instanceBlueOffset", "instanceAlphaOffset"],
    CAShapeLayer.self.description(): ["path", "fillColor", "lineDashPhase", "lineWidth", "miterLimit", "strokeColor", "strokeStart", "strokeEnd"],
    CATextLayer.self.description(): ["fontSize", "foregroundColor"]
]

public extension UIView.AnimationOptions {
    //CA Fill modes
    static let fillModeNone = UIView.AnimationOptions(rawValue: 0)
    static let fillModeForwards = UIView.AnimationOptions(rawValue: 1024)
    static let fillModeBackwards = UIView.AnimationOptions(rawValue: 2048)
    static let fillModeBoth = UIView.AnimationOptions(rawValue: 1024 + 2048)
    
    //CA Remove on completion
    static let isRemovedOnCompletion = UIView.AnimationOptions(rawValue: 0)
    static let isNotRemovedOnCompletion = UIView.AnimationOptions(rawValue: 16384)
}

/**
A `UIView` extension that adds super powers to animateWithDuration:animations: and the like.
Check the README for code examples of what features this extension adds.
*/

extension UIView {
    
    // MARK: UIView animation & action methods

    fileprivate static func replaceAnimationMethods() {
        //replace actionForLayer...
        if
            let origMethod = class_getInstanceMethod(self, #selector(UIView.action(for:forKey:))),
            let eaMethod = class_getInstanceMethod(self, #selector(UIView.EA_actionForLayer(_:forKey:))) {
            method_exchangeImplementations(origMethod, eaMethod)
        }
        
        //replace animateWithDuration...
        if
            let origMethod = class_getClassMethod(self, #selector(UIView.animate(withDuration:animations:))),
            let eaMethod = class_getClassMethod(self, #selector(UIView.EA_animate(withDuration:animations:))) {
            method_exchangeImplementations(origMethod, eaMethod)
        }
        
        if
            let origMethod = class_getClassMethod(self, #selector(UIView.animate(withDuration:animations:completion:))),
            let eaMethod = class_getClassMethod(self, #selector(UIView.EA_animate(withDuration:animations:completion:))) {
            method_exchangeImplementations(origMethod, eaMethod)
        }
        
        if
            let origMethod = class_getClassMethod(self, #selector(UIView.animate(withDuration:delay:options:animations:completion:))),
            let eaMethod = class_getClassMethod(self, #selector(UIView.EA_animate(withDuration:delay:options:animations:completion:))) {
            method_exchangeImplementations(origMethod, eaMethod)
        }
        
        if
            let origMethod = class_getClassMethod(self, #selector(UIView.animate(withDuration:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:))),
            let eaMethod = class_getClassMethod(self, #selector(UIView.EA_animate(withDuration:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:))) {
            method_exchangeImplementations(origMethod, eaMethod)
        }
        
    }
    
    @objc
    func EA_actionForLayer(_ layer: CALayer!, forKey key: String!) -> CAAction! {

        let result = EA_actionForLayer(layer, forKey: key)
        
        if let activeContext = EasyAnimation.activeAnimationContexts.last {
            if let _ = result as? NSNull {
                
                if vanillaLayerKeys.contains(key) ||
                    (specializedLayerKeys[layer.classForCoder.description()] != nil && specializedLayerKeys[layer.classForCoder.description()]!.contains(key)) {
                        
                        var currentKeyValue = layer.value(forKey: key)
                        
                        //exceptions
                        if currentKeyValue == nil && key.hasSuffix("Color") {
                            currentKeyValue = UIColor.clear.cgColor
                        }
                        
                        //found an animatable property - add the pending animation
                        if let currentKeyValue = currentKeyValue {
                            activeContext.pendingAnimations.append(
                                PendingAnimation(layer: layer, keyPath: key, fromValue: currentKeyValue)
                            )
                        }
                }
            } else {
                activeContext.nrOfUIKitAnimations+=1
            }
        }
        
        return result
    }
    
    @objc
    class func EA_animate(withDuration duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat, options: UIView.AnimationOptions, animations: () -> Void, completion: ((Bool) -> Void)?) {
        //create context
        let context = AnimationContext()
        context.duration = duration
        context.delay = delay
        context.options = options
        context.springDamping = dampingRatio
        context.springVelocity = velocity
        
        //push context
        EasyAnimation.activeAnimationContexts.append(context)
        
        //enable layer actions
        CATransaction.begin()
        CATransaction.setDisableActions(false)
        
        var completionBlock: CompletionBlock? = nil
        
        //spring animations
        if let completion = completion {
            //wrap a completion block
            completionBlock = CompletionBlock(context: context, completion: completion)
            EA_animate(withDuration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity, options: options, animations: animations, completion: completionBlock!.wrapCompletion)
        } else {
            //simply schedule the animation
            EA_animate(withDuration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity, options: options, animations: animations, completion: nil)
        }
        
        //pop context
        EasyAnimation.activeAnimationContexts.removeLast()
        
        //run pending animations
        for anim in context.pendingAnimations {
            anim.layer.add(EA_animation(anim, context: context), forKey: nil)
        }
        
        CATransaction.commit()
    }
    
    @objc
    class func EA_animate(withDuration duration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions, animations: () -> Void, completion: ((Bool) -> Void)?) {
        
        //create context
        let context = AnimationContext()
        context.duration = duration
        context.delay = delay
        context.options = options
        
        //push context
        EasyAnimation.activeAnimationContexts.append(context)
        
        //enable layer actions
        CATransaction.begin()
        CATransaction.setDisableActions(false)
        
        var completionBlock: CompletionBlock? = nil
        
        //animations
        if let completion = completion {
            //wrap a completion block
            completionBlock = CompletionBlock(context: context, completion: completion)
            EA_animate(withDuration: duration, delay: delay, options: options, animations: animations, completion: completionBlock!.wrapCompletion)
        } else {
            //simply schedule the animation
            EA_animate(withDuration: duration, delay: delay, options: options, animations: animations, completion: nil)
        }
        
        //pop context
        EasyAnimation.activeAnimationContexts.removeLast()
        
        //run pending animations
        for anim in context.pendingAnimations {
            //print("pending: \(anim.keyPath) from \(anim.fromValue) to \(anim.layer.value(forKeyPath: anim.keyPath))")
            anim.layer.add(EA_animation(anim, context: context), forKey: nil)
        }
        
        //try a timer now, than see about animation delegate
        if let completionBlock = completionBlock, context.nrOfUIKitAnimations == 0, context.pendingAnimations.count > 0 {
            Timer.scheduledTimer(timeInterval: context.duration, target: self, selector: #selector(UIView.EA_wrappedCompletionHandler(_:)), userInfo: completionBlock, repeats: false)
        }
        
        CATransaction.commit()
    }
    
    @objc
    class func EA_animate(withDuration duration: TimeInterval, animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
        animate(withDuration: duration, delay: 0.0, options: [], animations: animations, completion: completion)
    }
    
    @objc
    class func EA_animate(withDuration duration: TimeInterval, animations: @escaping () -> Void) {
        animate(withDuration: duration, animations: animations, completion: nil)
    }
    
    @objc
    class func EA_wrappedCompletionHandler(_ timer: Timer) {
        if let completionBlock = timer.userInfo as? CompletionBlock {
            completionBlock.wrapCompletion(true)
        }
    }

    // MARK: create CA animation
    
    private class func EA_animation(_ pending: PendingAnimation, context: AnimationContext) -> CAAnimation {
        
        let anim: CAAnimation
        
        if (context.springDamping > 0.0) {
            //create a layer spring animation

            if #available(iOS 9, *) { // iOS9!
                anim = CASpringAnimation(keyPath: pending.keyPath)
                if let anim = anim as? CASpringAnimation {
                    anim.fromValue = pending.fromValue
                    anim.toValue = pending.layer.value(forKey: pending.keyPath)

                    let epsilon = 0.001
                    anim.damping = CGFloat(-2.0 * log(epsilon) / context.duration)
                    anim.stiffness = CGFloat(pow(anim.damping, 2)) / CGFloat(pow(context.springDamping * 2, 2))
                    anim.mass = 1.0
                    anim.initialVelocity = 0.0
                }
            } else {
                anim = RBBSpringAnimation(keyPath: pending.keyPath)
                if let anim = anim as? RBBSpringAnimation {
                    anim.from = pending.fromValue
                    anim.to = pending.layer.value(forKey: pending.keyPath)
                    
                    //TODO: refine the spring animation setup
                    //lotta magic numbers to mimic UIKit springs
                    let epsilon = 0.001
                    anim.damping = -2.0 * log(epsilon) / context.duration
                    anim.stiffness = Double(pow(anim.damping, 2)) / Double(pow(context.springDamping * 2, 2))
                    anim.mass = 1.0
                    anim.velocity = 0.0
                }
            }
        } else {
            //create property animation
            anim = CABasicAnimation(keyPath: pending.keyPath)
            (anim as! CABasicAnimation).fromValue = pending.fromValue
            (anim as! CABasicAnimation).toValue = pending.layer.value(forKey: pending.keyPath)
        }
        
        anim.duration = context.duration
        
        if context.delay > 0.0 {
            anim.beginTime = context.currentTime + context.delay
            anim.fillMode = CAMediaTimingFillMode.backwards
        }
        
        //options
        if let options = context.options?.rawValue {
            
            if options & UIView.AnimationOptions.beginFromCurrentState.rawValue == 0 { //only repeat if not in a chain
                anim.autoreverses = (options & UIView.AnimationOptions.autoreverse.rawValue == UIView.AnimationOptions.autoreverse.rawValue)
                anim.repeatCount = (options & UIView.AnimationOptions.repeat.rawValue == UIView.AnimationOptions.repeat.rawValue) ? Float.infinity : 0
            }
            
            //easing
            var timingFunctionName = CAMediaTimingFunctionName.easeInEaseOut
            
            if options & UIView.AnimationOptions.curveLinear.rawValue == UIView.AnimationOptions.curveLinear.rawValue {
                //first check for linear (it's this way to take up only 2 bits)
                timingFunctionName = CAMediaTimingFunctionName.linear
            } else if options & UIView.AnimationOptions.curveEaseIn.rawValue == UIView.AnimationOptions.curveEaseIn.rawValue {
                timingFunctionName = CAMediaTimingFunctionName.easeIn
            } else if options & UIView.AnimationOptions.curveEaseOut.rawValue == UIView.AnimationOptions.curveEaseOut.rawValue {
                timingFunctionName = CAMediaTimingFunctionName.easeOut
            }
            
            anim.timingFunction = CAMediaTimingFunction(name: timingFunctionName)
            
            //fill mode
            if options & UIView.AnimationOptions.fillModeBoth.rawValue == UIView.AnimationOptions.fillModeBoth.rawValue {
                //both
                anim.fillMode = CAMediaTimingFillMode.both
            } else if options & UIView.AnimationOptions.fillModeForwards.rawValue == UIView.AnimationOptions.fillModeForwards.rawValue {
                //forward
                anim.fillMode = (anim.fillMode == CAMediaTimingFillMode.backwards) ? CAMediaTimingFillMode.both : CAMediaTimingFillMode.forwards
            } else if options & UIView.AnimationOptions.fillModeBackwards.rawValue == UIView.AnimationOptions.fillModeBackwards.rawValue {
                //backwards
                anim.fillMode = CAMediaTimingFillMode.backwards
            }
            
            //is removed on completion
            if options & UIView.AnimationOptions.isNotRemovedOnCompletion.rawValue == UIView.AnimationOptions.isNotRemovedOnCompletion.rawValue {
                anim.isRemovedOnCompletion = false
            } else {
                anim.isRemovedOnCompletion = true
            }
        }
        
        return anim
    }
    
    // MARK: chain animations
    
    /**
    Creates and runs an animation which allows other animations to be chained to it and to each other.
    
    :param: duration The animation duration in seconds
    :param: delay The delay before the animation starts
    :param: options A UIViewAnimationOptions bitmask (check UIView.animationWithDuration:delay:options:animations:completion: for more info)
    :param: animations Animation closure
    :param: completion Completion closure of type (Bool)->Void
    
    :returns: The created request.
    */
    public class func animateAndChain(withDuration duration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions, animations: @escaping () -> Void, completion: ((Bool) -> Void)?) -> EAAnimationFuture {
        
        let currentAnimation = EAAnimationFuture()
        currentAnimation.duration = duration
        currentAnimation.delay = delay
        currentAnimation.options = options
        currentAnimation.animations = animations
        currentAnimation.completion = completion
        
        currentAnimation.nextDelayedAnimation = EAAnimationFuture()
        currentAnimation.nextDelayedAnimation!.prevDelayedAnimation = currentAnimation
        currentAnimation.run()
        
        EAAnimationFuture.animations.append(currentAnimation)
        
        return currentAnimation.nextDelayedAnimation!
    }

    /**
    Creates and runs an animation which allows other animations to be chained to it and to each other.
    
    :param: duration The animation duration in seconds
    :param: delay The delay before the animation starts
    :param: usingSpringWithDamping the spring damping
    :param: initialSpringVelocity initial velocity of the animation
    :param: options A UIViewAnimationOptions bitmask (check UIView.animationWithDuration:delay:options:animations:completion: for more info)
    :param: animations Animation closure
    :param: completion Completion closure of type (Bool)->Void
    
    :returns: The created request.
    */
    public class func animateAndChain(withDuration duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat, options: UIView.AnimationOptions, animations: @escaping () -> Void, completion: ((Bool) -> Void)?) -> EAAnimationFuture {
        
        let currentAnimation = EAAnimationFuture()
        currentAnimation.duration = duration
        currentAnimation.delay = delay
        currentAnimation.options = options
        currentAnimation.animations = animations
        currentAnimation.completion = completion
        currentAnimation.springDamping = dampingRatio
        currentAnimation.springVelocity = velocity
        
        currentAnimation.nextDelayedAnimation = EAAnimationFuture()
        currentAnimation.nextDelayedAnimation!.prevDelayedAnimation = currentAnimation
        currentAnimation.run()
        
        EAAnimationFuture.animations.append(currentAnimation)
        
        return currentAnimation.nextDelayedAnimation!
    }
}

extension CALayer {
    // MARK: CALayer animations
    fileprivate static func replaceAnimationMethods() {
        //replace actionForKey
        if
            let origMethod = class_getInstanceMethod(self, #selector(CALayer.action(forKey:))),
            let eaMethod = class_getInstanceMethod(self, #selector(CALayer.EA_action(forKey:))) {
            method_exchangeImplementations(origMethod, eaMethod)
        }
    }
    
    @objc
    public func EA_action(forKey key: String!) -> CAAction! {
        
        //check if the layer has a view-delegate
        if let _ = delegate as? UIView {
            return EA_action(forKey: key) // -> this passes the ball to UIView.actionForLayer:forKey:
        }
        
        //create a custom easy animation and add it to the animation stack
        if let activeContext = EasyAnimation.activeAnimationContexts.last,
            vanillaLayerKeys.contains(key) ||
                (specializedLayerKeys[self.classForCoder.description()] != nil &&
                    specializedLayerKeys[self.classForCoder.description()]!.contains(key)) {
                        
                        var currentKeyValue = value(forKey: key)
                        
                        //exceptions
                        if currentKeyValue == nil && key.hasSuffix("Color") {
                            currentKeyValue = UIColor.clear.cgColor
                        }
                        
                        //found an animatable property - add the pending animation
                        if let currentKeyValue = currentKeyValue {
                            activeContext.pendingAnimations.append(
                                PendingAnimation(layer: self, keyPath: key, fromValue: currentKeyValue
                                )
                            )
                        }
        }
        
        return nil
    }
}
