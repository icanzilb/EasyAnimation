//
//  DemoMultipleAnimationsViewController.swift
//  DemoApp
//
//  Created by Marin Todorov on 5/29/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

class DemoMultipleAnimationsViewController: UIViewController {

    var viewCount = 0.0
    let maxViews = 190.0
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        spawn()
    }

    func spawn() {
        viewCount++
        if viewCount > maxViews {
            return
        }
        
        let v = UIView(frame: CGRect(x: 50, y: 100, width: 100, height: 100))
        v.backgroundColor = UIColor(hue: CGFloat(Double(self.view.subviews.count)/maxViews), saturation: 1.0, brightness: 1.0, alpha: 1.0)
        v.layer.cornerRadius = 50.0
        view.addSubview(v)
        
        let duration = 5.0
        
        UIView.animateAndChainWithDuration(duration, delay: 0.0, options: nil, animations: {
            v.center.y += 250.0
        }, completion: nil).animateWithDuration(duration, animations: {
            v.center.x += 200.0
        }).animateWithDuration(duration, animations: {
            v.center.y -= 250.0
        }).animateWithDuration(duration, delay: 0.0, options: .Repeat, animations: {
            v.center.x -= 200.0
        }, completion: nil)
        
        self.title = "\(viewCount)"
        
        delay(seconds: 0.10, {
            self.spawn()
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewCount = 1000.0
        
        for chain in EAAnimationDelayed.animations {
            chain.cancelAnimationChain()
        }
        
    }
}
