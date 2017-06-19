//
//  DemoLayerViewAnimationsViewController.swift
//  DemoApp
//
//  Created by Marin Todorov on 5/29/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

class DemoLayerViewAnimationsViewController: UIViewController {

    @IBOutlet weak var redSquare: UIView!
    @IBOutlet weak var blueSquare: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //animate the view and the layer
        UIView.animate(withDuration: 0.33, delay: 0.0, options: [.curveEaseOut, .repeat, .autoreverse],
            animations: { () -> Void in
                
                //view property animation
                self.redSquare.transform = CGAffineTransform(scaleX: 1.33, y: 1.5)
                    .concatenating(CGAffineTransform(translationX: 0.0, y: 50.0))

                //layer properties animations
                self.blueSquare.layer.cornerRadius = 30.0
                self.blueSquare.layer.borderWidth = 10.0
                self.blueSquare.layer.borderColor = UIColor.blue.cgColor
                self.blueSquare.layer.shadowColor = UIColor.gray.cgColor
                self.blueSquare.layer.shadowOffset = CGSize(width: 15.0, height: 15.0)
                self.blueSquare.layer.shadowOpacity = 0.5
                
                var trans3d = CATransform3DIdentity
                trans3d.m34 = -1.0/500.0

                let rotationTransform = CATransform3DRotate(trans3d, CGFloat(-Double.pi/4), 0.0, 1.0, 0.0)
                let translationTransform = CATransform3DMakeTranslation(-50.0, 0, 0)
                self.blueSquare.layer.transform = CATransform3DConcat(rotationTransform, translationTransform)
                
        }, completion: nil)
    }
}
