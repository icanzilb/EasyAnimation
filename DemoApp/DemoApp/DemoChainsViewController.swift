//
//  DemoChainsViewController.swift
//  DemoApp
//
//  Created by Marin Todorov on 5/29/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

class DemoChainsViewController: UIViewController {

    @IBOutlet weak var redSquare: UIView!
    @IBOutlet weak var blueSquare: UIView!
    
    @IBOutlet weak var redTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var redLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var blueTopConstraint: NSLayoutConstraint!
    
    weak var chain: EAAnimationDelayed?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // chain calls to animateWithDuration... to easily make animation sequences
        
        chain = UIView.animateAndChainWithDuration(1.0, delay: 0.0, options: nil, animations: {
            
            self.redTopConstraint.constant += 150.0
            self.redSquare.layoutIfNeeded()
            
        }, completion: nil).animateWithDuration(1.0, animations: {
            
            self.redLeftConstraint.constant += 150.0
            self.redSquare.layoutIfNeeded()
                
        }).animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: nil, animations: {
            
            self.redSquare.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            self.blueSquare.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 0.0, 0.0, 1.0)
            
        }, completion: nil).animateWithDuration(0.5, animations: {
            
            self.redTopConstraint.constant -= 150.0
            self.blueTopConstraint.constant -= 150.0
            self.view.layoutIfNeeded()
            
        }).animateWithDuration(2.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: .Repeat, animations: {

            self.redLeftConstraint.constant -= 150.0
            self.blueTopConstraint.constant += 150.0
            self.view.layoutIfNeeded()
            self.redSquare.transform = CGAffineTransformIdentity
            self.blueSquare.layer.transform = CATransform3DIdentity

            }, completion: {_ in
                println("sequence finished - will loop from start")
        })
        
    }

    @IBAction func actionCancelSequence(sender: AnyObject) {
        
        if let sender = sender as? UIButton {
            sender.setTitle("Cancelled", forState: .Normal)
            sender.enabled = false
        }
        
        chain?.cancelAnimationChain()
    }
    
}
