//: Spring Animation

import Foundation
import UIKit
import XCPlayground

func delay(seconds seconds: Double, completion:()->()) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
    
    dispatch_after(popTime, dispatch_get_main_queue()) {
        completion()
    }
}


let containerRect = CGRectMake(0, 0, 400, 600)
let containerView = UIView(frame: containerRect)
containerView.backgroundColor = UIColor.whiteColor()

let playground = XCPlaygroundPage.currentPage
playground.liveView = containerView

//MARK: Setup SubViews
var redSquare: UIView = UIView()
redSquare.backgroundColor = UIColor.redColor()
var blueSquare: UIView = UIView()
blueSquare.backgroundColor = UIColor.blueColor()
containerView.addSubview(redSquare)
containerView.addSubview(blueSquare)
redSquare.translatesAutoresizingMaskIntoConstraints = false
blueSquare.translatesAutoresizingMaskIntoConstraints = false
//MARK: Container view -to- buuttons relations
var redTopConstraint: NSLayoutConstraint = NSLayoutConstraint(item: redSquare, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: containerView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 50.0)
var redLeftConstraint: NSLayoutConstraint = NSLayoutConstraint(item: redSquare, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: containerView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 50.0)
var blueTopConstraint: NSLayoutConstraint = NSLayoutConstraint(item: blueSquare, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: containerView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 50.0)
var blueLeftConstraint: NSLayoutConstraint = NSLayoutConstraint(item: blueSquare, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: containerView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 250.0)


//MARK: redSquare constraints
var redwidth: NSLayoutConstraint = NSLayoutConstraint(item: redSquare, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 100)
var redHeightConstraint: NSLayoutConstraint = NSLayoutConstraint(item: redSquare, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 100)
redSquare.addConstraints([redwidth,redHeightConstraint])
redSquare.layoutIfNeeded()

//MARK: blueSquare Constraints
var bluewidth: NSLayoutConstraint = NSLayoutConstraint(item: blueSquare, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 100)
var blueheight: NSLayoutConstraint = NSLayoutConstraint(item: blueSquare, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 100)
blueSquare.addConstraints([bluewidth,blueheight])

containerView.addConstraints([redLeftConstraint,redTopConstraint,blueTopConstraint,blueLeftConstraint])
containerView.layoutIfNeeded()

//MARK: Animation
var chain: EAAnimationDelayed?

func startTheChain() {
    
    // chain calls to animateWithDuration... to easily make animation sequences
    
    chain = UIView.animateAndChainWithDuration(2.0, delay: 0.0, options: [], animations: {
        
        redTopConstraint.constant += 150.0
        redSquare.layoutIfNeeded()
        
        }, completion: nil).animateWithDuration(2.0, animations: {
            
            redLeftConstraint.constant += 150.0
            redSquare.layoutIfNeeded()
            
        }).animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: [], animations: {
            
            redSquare.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            blueSquare.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 0.0, 0.0, 1.0)
            
            }, completion: nil).animateWithDuration(0.5, animations: {
                
                redTopConstraint.constant -= 150.0
                blueTopConstraint.constant -= 150.0
                containerView.layoutIfNeeded()
                
            }).animateWithDuration(2.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: .Repeat, animations: {
                
                redLeftConstraint.constant -= 150.0
                blueTopConstraint.constant += 150.0
                containerView.layoutIfNeeded()
                redSquare.transform = CGAffineTransformIdentity
                blueSquare.layer.transform = CATransform3DIdentity
                
                }, completion: {_ in
                    print("sequence finished - will loop from start")
            })
    
}


func actionCancelSequence() {
    
    print("Cancel")
    chain!.cancelAnimationChain(completion: {
        
        redLeftConstraint.constant = 0
        redTopConstraint.constant = 0
        redSquare.transform = CGAffineTransformIdentity
        blueTopConstraint.constant = 0
        blueSquare.layer.transform  = CATransform3DIdentity
        
        UIView.animateWithDuration(0.5, animations: {
            containerView.layoutIfNeeded()
        })
    })
}


delay(seconds: 1.0) { () -> () in
    startTheChain()
}

delay(seconds: 10.0) { () -> () in
    actionCancelSequence()
}



let cancelbutotn = UIButton(frame: CGRectMake(150.0,300.0,150.0,40.0))
cancelbutotn.setTitle("Cancel Sequence", forState: UIControlState.Normal)
cancelbutotn.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
cancelbutotn.addTarget(playground, action: Selector("actionCancelSequence:"), forControlEvents: UIControlEvents.TouchUpInside)
containerView.addSubview(cancelbutotn)
    


 