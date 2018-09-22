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
    
    weak var chain: EAAnimationFuture?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // chain calls to animateWithDuration... to easily make animation sequences
        
        chain = UIView.animateAndChain(withDuration: 1.0, delay: 0.0, options: [], animations: {
            
            self.redTopConstraint.constant += 150.0
            self.view.layoutIfNeeded()
            
        }, completion: nil).animate(withDuration: 1.0, animations: {
            
            self.redLeftConstraint.constant += 150.0
            self.view.layoutIfNeeded()
                
        }).animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: [], animations: {
            
            self.redSquare.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/4))
            self.blueSquare.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi/4), 0.0, 0.0, 1.0)
            
        }, completion: nil).animate(withDuration: 0.5, animations: {
            
            self.redTopConstraint.constant -= 150.0
            self.blueTopConstraint.constant -= 150.0
            self.view.layoutIfNeeded()
            
        }).animate(withDuration: 2.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: .repeat, animations: {

            self.redLeftConstraint.constant -= 150.0
            self.blueTopConstraint.constant += 150.0
            self.view.layoutIfNeeded()
            self.redSquare.transform = CGAffineTransform.identity
            self.blueSquare.layer.transform = CATransform3DIdentity

        }, completion: {_ in
                print("sequence finished - will loop from start")
        })
        
    }

    @IBAction func actionCancelSequence(_ sender: AnyObject) {
        
        if let sender = sender as? UIButton {
          sender.setTitle("Cancelled", for: UIControl.State())
            sender.isEnabled = false
        }
        
        chain!.cancelAnimationChain({
            
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
