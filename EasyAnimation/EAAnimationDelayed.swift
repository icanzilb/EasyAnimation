//
//  EAAnimationDelayed.swift
//
//  Created by Marin Todorov on 5/26/15.
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

/**
A class that is used behind the scene to chain and/or delay animations.
You do not need to create instances directly - they are created automatically when you use
animateWithDuration:animation: and the like.
*/

public class EAAnimationDelayed: Equatable, CustomStringConvertible {
    
    /* debug helpers */
    private var debug: Bool = false
    private var debugNumber: Int = 0
    static private var debugCount: Int = 0
    
    /* animation properties */
    var duration: CFTimeInterval = 0.0
    var delay: CFTimeInterval = 0.0
    var options: UIViewAnimationOptions = []
    var animations: (() -> Void)?
    var completion: ((Bool) -> Void)?
    
    var identifier: String
    
    var springDamping: CGFloat = 0.0
    var springVelocity: CGFloat = 0.0
    
    private var loopsChain = false
    
    private static var cancelCompletions: [String: ()->Void] = [:]
    
    /* animation chain links */
    var prevDelayedAnimation: EAAnimationDelayed? {
        didSet {
            if let prev = prevDelayedAnimation {
                identifier = prev.identifier
            }
        }
    }
    var nextDelayedAnimation: EAAnimationDelayed?
    
    //MARK: - Animation lifecycle
    
    init() {
        EAAnimationDelayed.debugCount += 1
        self.debugNumber = EAAnimationDelayed.debugCount
        if debug {
            print("animation #\(self.debugNumber)")
        }
        self.identifier = NSUUID().UUIDString
    }
    
    deinit {
        if debug {
            print("deinit \(self)")
        }
    }
    
    /**
    An array of all "root" animations for all currently animating chains. I.e. this array contains
    the first link in each currently animating chain. Handy if you want to cancel all chains - just
    loop over `animations` and call `cancelAnimationChain` on each one.
    */
    public static var animations: [EAAnimationDelayed] = []
    
    //MARK: Animation methods
    
    public func animateWithDuration(duration: NSTimeInterval, animations: () -> Void) -> EAAnimationDelayed {
        return animateWithDuration(duration, animations: animations, completion: completion)
    }
    
    public func animateWithDuration(duration: NSTimeInterval, animations: () -> Void, completion: ((Bool) -> Void)?) -> EAAnimationDelayed {
        return animateWithDuration(duration, delay: delay, options: [], animations: animations, completion: completion)
    }
    
    public func animateWithDuration(duration: NSTimeInterval, delay: NSTimeInterval, options: UIViewAnimationOptions, animations: () -> Void, completion: ((Bool) -> Void)?) -> EAAnimationDelayed {
        return animateAndChainWithDuration(duration, delay: delay, options: options, animations: animations, completion: completion)
    }
    
    public func animateWithDuration(duration: NSTimeInterval, delay: NSTimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat, options: UIViewAnimationOptions, animations: () -> Void, completion: ((Bool) -> Void)?) -> EAAnimationDelayed {
        let anim = animateAndChainWithDuration(duration, delay: delay, options: options, animations: animations, completion: completion)
        self.springDamping = dampingRatio
        self.springVelocity = velocity
        return anim
    }
    
    public func animateAndChainWithDuration(duration: NSTimeInterval, delay: NSTimeInterval, options: UIViewAnimationOptions, animations: () -> Void, completion: ((Bool) -> Void)?) -> EAAnimationDelayed {
        var options = options
        
        if options.contains(.Repeat) {
            options.remove(.Repeat)
            loopsChain = true
        }
        
        self.duration = duration
        self.delay = delay
        self.options = options
        self.animations = animations
        self.completion = completion
        
        nextDelayedAnimation = EAAnimationDelayed()
        nextDelayedAnimation!.prevDelayedAnimation = self
        return nextDelayedAnimation!
    }
    
    //MARK: - Animation control methods
    
    /**
    A method to cancel the animation chain of the current animation.
    This method cancels and removes all animations that are chained to each other in one chain.
    The animations will not stop immediately - the currently running animation will finish and then
    the complete chain will be stopped and removed.
    
    :param: completion completion closure
    */
    
    public func cancelAnimationChain(completion completion: (()->Void)? = nil) {
        EAAnimationDelayed.cancelCompletions[identifier] = completion
        
        var link = self
        while link.nextDelayedAnimation != nil {
            link = link.nextDelayedAnimation!
        }
        
        link.detachFromChain()
        
        if debug {
            print("cancelled top animation: \(link)")
        }
    }
    
    private func detachFromChain() {
        self.nextDelayedAnimation = nil
        if let previous = self.prevDelayedAnimation {
            if debug {
                print("dettach \(self)")
            }
            previous.nextDelayedAnimation = nil
            previous.detachFromChain()
        } else {
            if let index = EAAnimationDelayed.animations.indexOf(self) {
                if debug {
                    print("cancel root animation #\(EAAnimationDelayed.animations[index])")
                }
                EAAnimationDelayed.animations.removeAtIndex(index)
            }
        }
        self.prevDelayedAnimation = nil
    }
    
    func run() {
        if debug {
            print("run animation #\(debugNumber)")
        }
        //TODO: Check if layer-only animations fire a proper completion block
        if let animations = animations {
            options.insert(.BeginFromCurrentState)
            let animationDelay = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * self.delay ))
            
            dispatch_after(animationDelay, dispatch_get_main_queue()) {
                if self.springDamping > 0.0 {
                    //spring animation
                    UIView.animateWithDuration(self.duration, delay: 0, usingSpringWithDamping: self.springDamping, initialSpringVelocity: self.springVelocity, options: self.options, animations: animations, completion: self.animationCompleted)
                } else {
                    //basic animation
                    UIView.animateWithDuration(self.duration, delay: 0, options: self.options, animations: animations, completion: self.animationCompleted)
                }
            }
        }
    }
    
    private func animationCompleted(finished: Bool) {
        
        //animation's own completion
        self.completion?(finished)
        
        //chain has been cancelled
        if let cancelCompletion = EAAnimationDelayed.cancelCompletions[identifier] {
            if debug {
                print("run chain cancel completion")
            }
            cancelCompletion()
            detachFromChain()
            return
        }
        
        //check for .Repeat
        if finished && self.loopsChain {
            //find first animation in the chain and run it next
            var link = self
            while link.prevDelayedAnimation != nil {
                link = link.prevDelayedAnimation!
            }
            if debug {
                print("loop to \(link)")
            }
            link.run()
            return
        }
        
        //run next or destroy chain
        if self.nextDelayedAnimation?.animations != nil {
            self.nextDelayedAnimation?.run()
        } else {
            //last animation in the chain
            self.detachFromChain()
        }
        
    }
    
    public var description: String {
        get {
            if debug {
                return "animation #\(self.debugNumber) [\(self.identifier)] prev: \(self.prevDelayedAnimation?.debugNumber) next: \(self.nextDelayedAnimation?.debugNumber)"
            } else {
                return "<EADelayedAnimation>"
            }
        }
    }
}

public func == (lhs: EAAnimationDelayed , rhs: EAAnimationDelayed) -> Bool {
    return lhs === rhs
}