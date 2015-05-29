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

public class EAAnimationDelayed: Equatable, Printable {
    
    /* debug helpers */
    private var debug: Bool = false
    private var debugNumber: Int = 0
    static private var debugCount: Int = 0
    
    /* animation properties */
    var duration: CFTimeInterval = 0.0
    var delay: CFTimeInterval = 0.0
    var options: UIViewAnimationOptions? = nil
    var animations: (() -> Void)?
    var completion: ((Bool) -> Void)?
    
    var springDamping: CGFloat = 0.0
    var springVelocity: CGFloat = 0.0
    
    private var loopsChain = false
    
    /* animation chain links */
    var prevDelayedAnimation: EAAnimationDelayed?
    var nextDelayedAnimation: EAAnimationDelayed?
    
    /**
        An array of all "root" animations for all currently animating chains. I.e. this array contains
        the first link in each currently animating chain. Handy if you want to cancel all chains - just
        loop over `animations` and call `cancelAnimationChain` on each one.
    */
    public static var animations: [EAAnimationDelayed] = []
    
    public func animateWithDuration(duration: NSTimeInterval, animations: () -> Void) -> EAAnimationDelayed {
        return animateWithDuration(duration, animations: animations, completion: completion)
    }
    
    public func animateWithDuration(duration: NSTimeInterval, animations: () -> Void, completion: ((Bool) -> Void)?) -> EAAnimationDelayed {
        return animateWithDuration(duration, delay: delay, options: nil, animations: animations, completion: completion)
    }
    
    public func animateWithDuration(duration: NSTimeInterval, delay: NSTimeInterval, options: UIViewAnimationOptions, animations: () -> Void, completion: ((Bool) -> Void)?) -> EAAnimationDelayed {
        return animateAndChainWithDuration(duration, delay: delay, options: options, animations: animations, completion: completion)
    }
    
    public func animateWithDuration(duration: NSTimeInterval, delay: NSTimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat, options: UIViewAnimationOptions, animations: () -> Void, completion: ((Bool) -> Void)?) -> EAAnimationDelayed {
        var anim = animateAndChainWithDuration(duration, delay: delay, options: options, animations: animations, completion: completion)
        self.springDamping = dampingRatio
        self.springVelocity = velocity
        return anim
    }
    
    public func animateAndChainWithDuration(duration: NSTimeInterval, delay: NSTimeInterval, options: UIViewAnimationOptions, animations: () -> Void, completion: ((Bool) -> Void)?) -> EAAnimationDelayed {
        
        self.duration = duration
        self.delay = delay
        self.options = options
        self.animations = animations
        self.completion = completion
        
        if let options = self.options?.rawValue {
            if options & UIViewAnimationOptions.Repeat.rawValue != 0 {
                self.options = UIViewAnimationOptions(rawValue: self.options!.rawValue & ~UIViewAnimationOptions.Repeat.rawValue)
                self.loopsChain = true
            }
        }
        
        self.nextDelayedAnimation = EAAnimationDelayed()
        self.nextDelayedAnimation!.prevDelayedAnimation = self
        return self.nextDelayedAnimation!
    }
    
    /**
        A method to cancel the animation chain of the current animation.
        This method cancels and removes all animations that are chained to each other in one chain.
        The animations will not stop immediately - the currently running animation will finish and then 
        the complete chain will be stopped and removed.
    */
    public func cancelAnimationChain() {
        var link = self
        while link.nextDelayedAnimation != nil {
            link = link.nextDelayedAnimation!
        }

        link.detachFromChain()

        if debug {
            println("cancelled top animation: \(link)")
        }
    }
    
    private func detachFromChain() {
        self.nextDelayedAnimation = nil
        if let previous = self.prevDelayedAnimation {
            if debug {
                println("dettach \(self)")
            }
            self.prevDelayedAnimation?.nextDelayedAnimation = nil
            self.prevDelayedAnimation?.detachFromChain()
        } else {
            if let index = find(EAAnimationDelayed.animations, self) {
                if debug {
                    println("cancel root animation #\(EAAnimationDelayed.animations[index])")
                }
                EAAnimationDelayed.animations.removeAtIndex(index)
            }
        }
        self.prevDelayedAnimation = nil
    }
    
    func run() {
        if let animations = animations {
            if self.springDamping > 0.0 {
                //spring animation
                UIView.animateWithDuration(self.duration, delay: self.delay, usingSpringWithDamping: self.springDamping, initialSpringVelocity: self.springVelocity, options: self.options ?? nil, animations: animations, completion: self.animationCompleted)
            } else {
                //basic animation
                UIView.animateWithDuration(self.duration, delay: self.delay, options: self.options ?? nil, animations: animations, completion: self.animationCompleted)
            }
        }
    }
    
    private func animationCompleted(finished: Bool) {
        
        self.completion?(finished)
        
        //check for .Repeat
        if finished && self.loopsChain {
            //find first animation in the chain and run it next
            var link = self
            while link.prevDelayedAnimation != nil {
                link = link.prevDelayedAnimation!
            }
            if debug {
                println("loop to \(link)")
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
    
    init() {
        EAAnimationDelayed.debugCount++
        self.debugNumber = EAAnimationDelayed.debugCount
        if debug {
            println("animation #\(self.debugNumber)")
        }
    }
    
    deinit {
        if debug {
            println("deinit \(self)")
        }
    }
    
    public var description: String {
        get {
            if debug {
                return "animation #\(self.debugNumber) prev: \(self.prevDelayedAnimation?.debugNumber) next: \(self.nextDelayedAnimation?.debugNumber)"
            } else {
                return "<EADelayedAnimation>"
            }
        }
    }
}

public func == (lhs: EAAnimationDelayed , rhs: EAAnimationDelayed) -> Bool {
    return lhs === rhs
}