//: Spring Animation

import Foundation
import UIKit
import XCPlayground
import PlaygroundSupport


func delay(seconds: Double, completion:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: {
        completion()
    })
}




let containerRect = CGRect(x: 0,y: 0,width: 400,height: 800)
let containerView = UIView(frame: containerRect)
containerView.backgroundColor = UIColor.white

PlaygroundPage.current.liveView = containerView


//MARK: Setup SubViews
var redSquare: UIView = UIView()
redSquare.backgroundColor = UIColor.red
var blueSquare: UIView = UIView()
blueSquare.backgroundColor = UIColor.blue
containerView.addSubview(redSquare)
containerView.addSubview(blueSquare)
redSquare.translatesAutoresizingMaskIntoConstraints = false
blueSquare.translatesAutoresizingMaskIntoConstraints = false
//MARK: Container view -to- buuttons relations
var redTopConstraint: NSLayoutConstraint = NSLayoutConstraint(item: redSquare, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 50.0)
var redLeftConstraint: NSLayoutConstraint = NSLayoutConstraint(item: redSquare, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 50.0)
var blueTopConstraint: NSLayoutConstraint = NSLayoutConstraint(item: blueSquare, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 50.0)
var blueLeftConstraint: NSLayoutConstraint = NSLayoutConstraint(item: blueSquare, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 250.0)


//MARK: redSquare constraints
var redwidth: NSLayoutConstraint = NSLayoutConstraint(item: redSquare, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 100)
var redHeightConstraint: NSLayoutConstraint = NSLayoutConstraint(item: redSquare, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 100)
redSquare.addConstraints([redwidth,redHeightConstraint])
redSquare.layoutIfNeeded()

//MARK: blueSquare Constraints
var bluewidth: NSLayoutConstraint = NSLayoutConstraint(item: blueSquare, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 100)
var blueheight: NSLayoutConstraint = NSLayoutConstraint(item: blueSquare, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 100)
blueSquare.addConstraints([bluewidth,blueheight])

containerView.addConstraints([redLeftConstraint,redTopConstraint,blueTopConstraint,blueLeftConstraint])
containerView.layoutIfNeeded()

//MARK: Animation
var chain: EAAnimationFuture?

func startTheChain() {
    
    // chain calls to animateWithDuration... to easily make animation sequences
    chain = UIView.animateAndChain(withDuration: 2.0, delay: 0.0, options: [], animations: { 
        redTopConstraint.constant += 150.0
        redSquare.layoutIfNeeded()
    }, completion: nil).animate(withDuration: 2.0, delay: 0.0, options: [], animations: { 
        redLeftConstraint.constant += 150.0
        redSquare.layoutIfNeeded()
    }, completion: nil).animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: [], animations: { 
        redSquare.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
        blueSquare.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 0.0, 0.0, 1.0)
        
    }, completion: nil).animate(withDuration: 0.2, animations: { 
        redTopConstraint.constant -= 150.0
        blueTopConstraint.constant -= 150.0
        containerView.layoutIfNeeded()
        
    }).animate(withDuration: 2.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options:.repeat, animations: {
        redLeftConstraint.constant -= 150.0
        blueTopConstraint.constant += 150.0
        containerView.layoutIfNeeded()
        redSquare.transform = CGAffineTransform.identity
        blueSquare.layer.transform = CATransform3DIdentity
        
    }, completion: { (f) in
        print("sequence finished - will loop from start")

    })
    
    
}


func actionCancelSequence() {
    
    print("Cancel")
    chain!.cancelAnimationChain({
        
        redLeftConstraint.constant = 0
        redTopConstraint.constant = 0
        redSquare.transform = CGAffineTransform.identity
        blueTopConstraint.constant = 0
        blueSquare.layer.transform  = CATransform3DIdentity
        
        UIView.animate(withDuration: 0.5, animations: {
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



let cancelbutotn = UIButton(frame: CGRect(x: 150.0,y:300.0,width:150.0,height:40.0))
cancelbutotn.setTitle("Cancel Sequence", for: UIControlState.normal)
cancelbutotn.setTitleColor(UIColor.blue, for: UIControlState.normal)
cancelbutotn.addTarget(PlaygroundPage.current, action: Selector(("actionCancelSequence:")), for: UIControlEvents.touchUpInside)
containerView.addSubview(cancelbutotn)
    


 
