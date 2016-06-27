//
//  DemoSpringAnimationsViewController.swift
//  DemoApp
//
//  Created by Marin Todorov on 5/29/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

class DemoSpringAnimationsViewController: UIViewController {

    
    @IBOutlet weak var redSquare: UIView!
    @IBOutlet weak var blueSquare: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animate()
    }
    
    func animate() {
        
        UIView.animateAndChainWithDuration(duration: 1.0, delay: 0.0, usingSpringWithDamping: 0.33, initialSpringVelocity: 0.0, options: [],
            animations: {
                //spring animate the view
                self.redSquare.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2)).concat(
                    CGAffineTransform(scaleX: 1.5, y: 1.5)
                )
                
                //spring animate the layer
                self.blueSquare.layer.transform = CATransform3DConcat(
                    CATransform3DMakeRotation(CGFloat(-M_PI_2), 0.0, 0.0, 1.0),
                    CATransform3DMakeScale(1.33, 1.33, 1.33)
                )
                self.blueSquare.layer.cornerRadius = 50.0

            }, completion: nil).animateWithDuration(duration: 1.0, delay: 0.0, usingSpringWithDamping: 0.33, initialSpringVelocity: 0.0, options: .repeat,
            animations: {
                
                //spring animate the view
                self.redSquare.transform = CGAffineTransform.identity
                
                //spring animate the layer
                self.blueSquare.layer.transform = CATransform3DIdentity
                self.blueSquare.layer.cornerRadius = 0.0
                
            }, completion: nil)
    }
    
}
