
//: Spring Animation

import Foundation
import UIKit
import XCPlayground



let containerRect = CGRectMake(0, 0, 400, 800)
let containerView = UIView(frame: containerRect)
containerView.backgroundColor = UIColor.whiteColor()

let playground = XCPlaygroundPage.currentPage
playground.liveView = containerView




    let redSquare: UIView = UIView(frame: CGRectMake(50,50,100,100))
    redSquare.backgroundColor = UIColor.redColor()
    containerView.addSubview(redSquare)

    let blueSquare: UIView = UIView(frame: CGRectMake(250,50,100,100))
    blueSquare.backgroundColor = UIColor.blueColor()
    containerView.addSubview(blueSquare)

    //animate the view and the layer
    UIView.animateWithDuration(0.33, delay: 0.0, options: [.CurveEaseOut, .Repeat, .Autoreverse],
        animations: { () -> Void in
            
            //view property animation
            redSquare.transform = CGAffineTransformConcat(
                CGAffineTransformMakeScale(1.33, 1.5),
                CGAffineTransformMakeTranslation(0.0, 50.0)
            )
            
            //layer properties animations
            blueSquare.layer.cornerRadius = 30.0
            blueSquare.layer.borderWidth = 10.0
            blueSquare.layer.borderColor = UIColor.blueColor().CGColor
            blueSquare.layer.shadowColor = UIColor.grayColor().CGColor
            blueSquare.layer.shadowOffset = CGSize(width: 15.0, height: 15.0)
            blueSquare.layer.shadowOpacity = 0.5
            
            var trans3d = CATransform3DIdentity
            trans3d.m34 = -1.0/500.0
            
            let rotationTransform = CATransform3DRotate(trans3d, CGFloat(-M_PI_4), 0.0, 1.0, 0.0)
            let translationTransform = CATransform3DMakeTranslation(-50.0, 0, 0)
            blueSquare.layer.transform = CATransform3DConcat(rotationTransform, translationTransform)
            
        }, completion: nil)


