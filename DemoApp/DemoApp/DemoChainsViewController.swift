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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // chain calls to animateWithDuration... to easily make animation sequences
        
        chain = UIView.animateAndChainWithDuration(duration: 1.0, delay: 0.0, options: [], animations: {
            
            self.redTopConstraint.constant += 150.0
            self.redSquare.layoutIfNeeded()
            
        }, completion: nil).animateWithDuration(duration: 1.0, animations: {
            
            self.redLeftConstraint.constant += 150.0
            self.redSquare.layoutIfNeeded()
                
        }).animateWithDuration(duration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: [], animations: {
            
            self.redSquare.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
            self.blueSquare.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 0.0, 0.0, 1.0)
            
        }, completion: nil).animateWithDuration(duration: 0.5, animations: {
            
            self.redTopConstraint.constant -= 150.0
            self.blueTopConstraint.constant -= 150.0
            self.view.layoutIfNeeded()
            
        }).animateWithDuration(duration: 2.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: .repeat, animations: {

            self.redLeftConstraint.constant -= 150.0
            self.blueTopConstraint.constant += 150.0
            self.view.layoutIfNeeded()
            self.redSquare.transform = CGAffineTransform.identity
            self.blueSquare.layer.transform = CATransform3DIdentity

            }, completion: {_ in
                print("sequence finished - will loop from start")
        })
        
    }

    @IBAction func actionCancelSequence(sender: AnyObject) {
        
        if let sender = sender as? UIButton {
            sender.setTitle("Cancelled", for: [])
            sender.isEnabled = false
        }
        
        chain!.cancelAnimationChain(completion: {
            
            self.redLeftConstraint.constant = 0
            self.redTopConstraint.constant = 0
            self.redSquare.transform = CGAffineTransform.identity
            self.blueTopConstraint.constant = 0
            self.blueSquare.layer.transform  = CATransform3DIdentity

            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        })
    }
    
}
