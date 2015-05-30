//
//  DemoPathAnimationViewController.swift
//  DemoApp
//
//  Created by Marin Todorov on 5/30/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

class DemoPathAnimationViewController: UIViewController {

    var showingAnimation = false
    
    override func viewDidLayoutSubviews() {
        if !showingAnimation {
            showAnimation(UIColor.redColor(), delay: 0.00)
            showAnimation(UIColor.blueColor(), delay: 0.25)
            showAnimation(UIColor.greenColor(), delay: 0.50)
            showingAnimation = true
        }
    }
    
    func showAnimation(color: UIColor, delay: CFTimeInterval) {
        let pathRect = CGRectInset(self.view.frame, 60, 80)
        
        //add the red square to animate
        let square = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        square.backgroundColor = color
        view.addSubview(square)
        
        //here you create the path animation by setting the animationPath property on your view
        UIView.animateWithDuration(2.0, delay: delay, options: .Repeat | .Autoreverse, animations: {
            square.animationPath = UIBezierPath(ovalInRect: pathRect).CGPath
        }, completion: nil)
        
        //draw the animation path on screen
        let oval = CAShapeLayer()
        oval.path = UIBezierPath(ovalInRect: pathRect).CGPath
        oval.strokeColor = UIColor.orangeColor().CGColor
        oval.fillColor = UIColor.whiteColor().CGColor
        oval.lineDashPattern = [3, 5]
        oval.lineWidth = 3.0
        view.layer.addSublayer(oval)
    }
    
}
