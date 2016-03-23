//
//  EasyAnimation.swift
//
//  Created by Marin Todorov on 4/11/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
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
    let fromValue: AnyObject
}

private class AnimationContext {
    var duration: NSTimeInterval = 1.0
    var currentTime: NSTimeInterval = {CACurrentMediaTime()}()
    var delay: NSTimeInterval = 0.0
    var options: UIViewAnimationOptions? = nil
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
    
    init(context c: AnimationContext, completion cb: (Bool) -> Void) {
        context = c
        completion = cb
    }
    
    func wrapCompletion(completed: Bool) {
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

private var didEAInitialize = false
private var didEAForLayersInitialize = false
private var activeAnimationContexts = [AnimationContext]()

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
    //TODO: test animating arrays, eg colors & locations
    CAGradientLayer.self.description(): ["colors", "locations", "endPoint", "startPoint"],
    CAReplicatorLayer.self.description(): ["instanceDelay", "instanceTransform", "instanceColor", "instanceRedOffset", "instanceGreenOffset", "instanceBlueOffset", "instanceAlphaOffset"],
    //TODO: test animating paths
    CAShapeLayer.self.description(): ["path", "fillColor", "lineDashPhase", "lineWidth", "miterLimit", "strokeColor", "strokeStart", "strokeEnd"],
    CATextLayer.self.description(): ["fontSize", "foregroundColor"]
]

public extension UIViewAnimationOptions {
    //CA Fill modes
    static let FillModeNone = UIViewAnimationOptions(rawValue: 0)
    static let FillModeForwards = UIViewAnimationOptions(rawValue: 1024)
    static let FillModeBackwards = UIViewAnimationOptions(rawValue: 2048)
    static let FillModeBoth = UIViewAnimationOptions(rawValue: 1024 + 2048)
}

/**
A `UIView` extension that adds super powers to animateWithDuration:animations: and the like.
Check the README for code examples of what features this extension adds.
*/

extension UIView {
    
    //TODO: experiment more with path animations
    //public var animationPath: CGPath? { set {} get {return nil}}
    
    // MARK: UIView animation & action methods
    
    override public static func initialize() {
        if !didEAInitialize {
            replaceAnimationMethods()
            didEAInitialize = true
        }
    }
    
    private static func replaceAnimationMethods() {
        //replace actionForLayer...
        method_exchangeImplementations(
            class_getInstanceMethod(self, #selector(UIView.actionForLayer(_:forKey:))),
            class_getInstanceMethod(self, #selector(UIView.EA_actionForLayer(_:forKey:))))
        
        //replace animateWithDuration...
        method_exchangeImplementations(
            class_getClassMethod(self, #selector(UIView.animateWithDuration(_:animations:))),
            class_getClassMethod(self, #selector(UIView.EA_animateWithDuration(_:animations:))))
        method_exchangeImplementations(
            class_getClassMethod(self, #selector(UIView.animateWithDuration(_:animations:completion:))),
            class_getClassMethod(self, #selector(UIView.EA_animateWithDuration(_:animations:completion:))))
        method_exchangeImplementations(
            class_getClassMethod(self, #selector(UIView.animateWithDuration(_:delay:options:animations:completion:))),
            class_getClassMethod(self, #selector(UIView.EA_animateWithDuration(_:delay:options:animations:completion:))))
        method_exchangeImplementations(
            class_getClassMethod(self, #selector(UIView.animateWithDuration(_:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:))),
            class_getClassMethod(self, #selector(UIView.EA_animateWithDuration(_:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:))))
        
    }
    
    func EA_actionForLayer(layer: CALayer!, forKey key: String!) -> CAAction! {
        
        let result = EA_actionForLayer(layer, forKey: key)
        
        if let activeContext = activeAnimationContexts.last {
            if let _ = result as? NSNull {
                
                if vanillaLayerKeys.contains(key) ||
                    (specializedLayerKeys[layer.classForCoder.description()] != nil && specializedLayerKeys[layer.classForCoder.description()]!.contains(key)) {
                        
                        var currentKeyValue: AnyObject? = layer.valueForKey(key)
                        
                        //exceptions
                        if currentKeyValue == nil && key.hasSuffix("Color") {
                            currentKeyValue = UIColor.clearColor().CGColor
                        }
                        
                        //found an animatable property - add the pending animation
                        if let currentKeyValue: AnyObject = currentKeyValue {
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
    
    class func EA_animateWithDuration(duration: NSTimeInterval, delay: NSTimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat, options: UIViewAnimationOptions, animations: () -> Void, completion: ((Bool) -> Void)?) {
        //create context
        let context = AnimationContext()
        context.duration = duration
        context.delay = delay
        context.options = options
        context.springDamping = dampingRatio
        context.springVelocity = velocity
        
        //push context
        activeAnimationContexts.append(context)
        
        //enable layer actions
        CATransaction.begin()
        CATransaction.setDisableActions(false)
        
        var completionBlock: CompletionBlock? = nil
        
        //spring animations
        if let completion = completion {
            //wrap a completion block
            completionBlock = CompletionBlock(context: context, completion: completion)
            EA_animateWithDuration(duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity, options: options, animations: animations, completion: completionBlock!.wrapCompletion)
        } else {
            //simply schedule the animation
            EA_animateWithDuration(duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity, options: options, animations: animations, completion: nil)
        }
        
        //pop context
        activeAnimationContexts.removeLast()
        
        //run pending animations
        for anim in context.pendingAnimations {
            anim.layer.addAnimation(EA_animation(anim, context: context), forKey: nil)
        }
        
        CATransaction.commit()
    }
    
    class func EA_animateWithDuration(duration: NSTimeInterval, delay: NSTimeInterval, options: UIViewAnimationOptions, animations: () -> Void, completion: ((Bool) -> Void)?) {
        
        //create context
        let context = AnimationContext()
        context.duration = duration
        context.delay = delay
        context.options = options
        
        //push context
        activeAnimationContexts.append(context)
        
        //enable layer actions
        CATransaction.begin()
        CATransaction.setDisableActions(false)
        
        var completionBlock: CompletionBlock? = nil
        
        //animations
        if let completion = completion {
            //wrap a completion block
            completionBlock = CompletionBlock(context: context, completion: completion)
            EA_animateWithDuration(duration, delay: delay, options: options, animations: animations, completion: completionBlock!.wrapCompletion)
        } else {
            //simply schedule the animation
            EA_animateWithDuration(duration, delay: delay, options: options, animations: animations, completion: nil)
        }
        
        //pop context
        activeAnimationContexts.removeLast()
        
        //run pending animations
        for anim in context.pendingAnimations {
            anim.layer.addAnimation(EA_animation(anim, context: context), forKey: nil)
        }
        
        //try a timer now, than see about animation delegate
        if let completionBlock = completionBlock where context.nrOfUIKitAnimations == 0 && context.pendingAnimations.count > 0 {
            NSTimer.scheduledTimerWithTimeInterval(context.duration, target: self, selector: #selector(UIView.EA_wrappedCompletionHandler(_:)), userInfo: completionBlock, repeats: false)
        }
        
        CATransaction.commit()
    }
    
    class func EA_animateWithDuration(duration: NSTimeInterval, animations: () -> Void, completion: ((Bool) -> Void)?) {
        animateWithDuration(duration, delay: 0.0, options: [], animations: animations, completion: completion)
    }
    
    class func EA_animateWithDuration(duration: NSTimeInterval, animations: () -> Void) {
        animateWithDuration(duration, animations: animations, completion: nil)
    }
    
    class func EA_wrappedCompletionHandler(timer: NSTimer) {
        if let completionBlock = timer.userInfo as? CompletionBlock {
            completionBlock.wrapCompletion(true)
        }
    }

    // MARK: create CA animation
    
    private class func EA_animation(pending: PendingAnimation, context: AnimationContext) -> CAAnimation {
        
        let anim: CAAnimation
        
        if (context.springDamping > 0.0) {
            //create a layer spring animation

            if #available(iOS 9, *) { // iOS9!
                anim = CASpringAnimation(keyPath: pending.keyPath)
                if let anim = anim as? CASpringAnimation {
                    anim.fromValue = pending.fromValue
                    anim.toValue = pending.layer.valueForKey(pending.keyPath)

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
                    anim.to = pending.layer.valueForKey(pending.keyPath)
                    
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
            (anim as! CABasicAnimation).toValue = pending.layer.valueForKey(pending.keyPath)
        }
        
        anim.duration = context.duration
        
        if context.delay > 0.0 {
            anim.beginTime = context.currentTime + context.delay
            anim.fillMode = kCAFillModeBackwards
        }
        
        //options
        if let options = context.options?.rawValue {
            
            if options & UIViewAnimationOptions.BeginFromCurrentState.rawValue == 0 { //only repeat if not in a chain
                anim.autoreverses = (options & UIViewAnimationOptions.Autoreverse.rawValue == UIViewAnimationOptions.Autoreverse.rawValue)
                anim.repeatCount = (options & UIViewAnimationOptions.Repeat.rawValue == UIViewAnimationOptions.Repeat.rawValue) ? Float.infinity : 0
            }
            
            //easing
            var timingFunctionName = kCAMediaTimingFunctionEaseInEaseOut
            
            if options & UIViewAnimationOptions.CurveLinear.rawValue == UIViewAnimationOptions.CurveLinear.rawValue {
                //first check for linear (it's this way to take up only 2 bits)
                timingFunctionName = kCAMediaTimingFunctionLinear
            } else if options & UIViewAnimationOptions.CurveEaseIn.rawValue == UIViewAnimationOptions.CurveEaseIn.rawValue {
                timingFunctionName = kCAMediaTimingFunctionEaseIn
            } else if options & UIViewAnimationOptions.CurveEaseOut.rawValue == UIViewAnimationOptions.CurveEaseOut.rawValue {
                timingFunctionName = kCAMediaTimingFunctionEaseOut
            }
            
            anim.timingFunction = CAMediaTimingFunction(name: timingFunctionName)
            
            //fill mode
            if options & UIViewAnimationOptions.FillModeBoth.rawValue == UIViewAnimationOptions.FillModeBoth.rawValue {
                //both
                anim.fillMode = kCAFillModeBoth
            } else if options & UIViewAnimationOptions.FillModeForwards.rawValue == UIViewAnimationOptions.FillModeForwards.rawValue {
                //forward
                anim.fillMode = (anim.fillMode == kCAFillModeBackwards) ? kCAFillModeBoth : kCAFillModeForwards
            } else if options & UIViewAnimationOptions.FillModeBackwards.rawValue == UIViewAnimationOptions.FillModeBackwards.rawValue {
                //backwards
                anim.fillMode = kCAFillModeBackwards
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
    public class func animateAndChainWithDuration(duration: NSTimeInterval, delay: NSTimeInterval, options: UIViewAnimationOptions, animations: () -> Void, completion: ((Bool) -> Void)?) -> EAAnimationDelayed {
        
        let currentAnimation = EAAnimationDelayed()
        currentAnimation.duration = duration
        currentAnimation.delay = delay
        currentAnimation.options = options
        currentAnimation.animations = animations
        currentAnimation.completion = completion
        
        currentAnimation.nextDelayedAnimation = EAAnimationDelayed()
        currentAnimation.nextDelayedAnimation!.prevDelayedAnimation = currentAnimation
        currentAnimation.run()
        
        EAAnimationDelayed.animations.append(currentAnimation)
        
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
    public class func animateAndChainWithDuration(duration: NSTimeInterval, delay: NSTimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat, options: UIViewAnimationOptions, animations: () -> Void, completion: ((Bool) -> Void)?) -> EAAnimationDelayed {
        
        let currentAnimation = EAAnimationDelayed()
        currentAnimation.duration = duration
        currentAnimation.delay = delay
        currentAnimation.options = options
        currentAnimation.animations = animations
        currentAnimation.completion = completion
        currentAnimation.springDamping = dampingRatio
        currentAnimation.springVelocity = velocity
        
        currentAnimation.nextDelayedAnimation = EAAnimationDelayed()
        currentAnimation.nextDelayedAnimation!.prevDelayedAnimation = currentAnimation
        currentAnimation.run()
        
        EAAnimationDelayed.animations.append(currentAnimation)
        
        return currentAnimation.nextDelayedAnimation!
    }
}

extension CALayer {
    // MARK: CALayer animations
    
    override public static func initialize() {
        super.initialize()
        
        if !didEAForLayersInitialize {
            replaceAnimationMethods()
            didEAForLayersInitialize = true
        }
    }
    
    private static func replaceAnimationMethods() {
        //replace actionForKey
        method_exchangeImplementations(
            class_getInstanceMethod(self, #selector(CALayer.actionForKey(_:))),
            class_getInstanceMethod(self, #selector(CALayer.EA_actionForKey(_:))))
    }
    
    public func EA_actionForKey(key: String!) -> CAAction! {
        
        //check if the layer has a view-delegate
        if let _ = delegate as? UIView {
            return EA_actionForKey(key) // -> this passes the ball to UIView.actionForLayer:forKey:
        }
        
        //create a custom easy animation and add it to the animation stack
        if let activeContext = activeAnimationContexts.last where
            vanillaLayerKeys.contains(key) ||
                (specializedLayerKeys[self.classForCoder.description()] != nil &&
                    specializedLayerKeys[self.classForCoder.description()]!.contains(key)) {
                        
                        var currentKeyValue: AnyObject? = valueForKey(key)
                        
                        //exceptions
                        if currentKeyValue == nil && key.hasSuffix("Color") {
                            currentKeyValue = UIColor.clearColor().CGColor
                        }
                        
                        //found an animatable property - add the pending animation
                        if let currentKeyValue: AnyObject = currentKeyValue {
                            activeContext.pendingAnimations.append(
                                PendingAnimation(layer: self, keyPath: key, fromValue: currentKeyValue
                                )
                            )
                        }
        }
        
        return nil
    }
}
