//
//  DemoMultipleAnimationsViewController.swift
//  DemoApp
//
//  Created by Marin Todorov on 5/29/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

class DemoMultipleAnimationsViewController: UIViewController {

    var viewCount: Int = 0
    let maxViews: Int = 190
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        spawn()
    }

    func spawn() {
        viewCount += 1
        if viewCount > maxViews {
            return
        }
        
        let v = UIView(frame: CGRect(x: 50, y: 100, width: 100, height: 100))
        v.backgroundColor = UIColor(hue: CGFloat(Double(self.view.subviews.count)/Double(maxViews)), saturation: 1.0, brightness: 1.0, alpha: 1.0)
        v.layer.cornerRadius = 50.0
        view.addSubview(v)
        
        let duration = 5.0

        UIView.animateAndChain(withDuration: duration, delay: 0.0, options: [], animations: {
            v.center.y += 250.0
            }, completion: nil).animate(withDuration: duration, animations: {
            v.center.x += 200.0
            }).animate(withDuration: duration, animations: {
            v.center.y -= 250.0
            }).animate(withDuration: duration, delay: 0.0, options: .repeat, animations: {
            v.center.x -= 200.0
        }, completion: nil)
        
        self.title = "\(viewCount) views"
        
        delay(seconds: 0.10, completion: {
            self.spawn()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewCount = 1000
        
        for chain in EAAnimationFuture.animations {
            chain.cancelAnimationChain()
        }
        
    }
}
