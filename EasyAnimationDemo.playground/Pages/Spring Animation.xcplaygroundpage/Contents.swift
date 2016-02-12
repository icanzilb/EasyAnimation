//: Spring Animation

import Foundation
import UIKit
import XCPlayground


let containerRect = CGRectMake(0, 0, 400, 800)
let containerView = UIView(frame: containerRect)
containerView.backgroundColor = UIColor.whiteColor()


let redSquare = UIView(frame: CGRectMake(50,100,100,100))
redSquare.backgroundColor = UIColor.redColor()
containerView.addSubview(redSquare)

let blueSquare = UIView(frame: CGRectMake(250,100,100,100))
blueSquare.backgroundColor = UIColor.blueColor()
blueSquare.layer.borderColor = UIColor(white: 0.2, alpha: 1.0).CGColor
containerView.addSubview(blueSquare)


/// Animation function
func animate() {
    
    UIView.animateAndChainWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.33, initialSpringVelocity: 0.0, options: [],
        animations: {
            //spring animate the view
            redSquare.transform = CGAffineTransformConcat(
                CGAffineTransformMakeRotation(CGFloat(M_PI_2)),
                CGAffineTransformMakeScale(1.5, 1.5)
            )
            
            //spring animate the layer
            blueSquare.layer.transform = CATransform3DConcat(
                CATransform3DMakeRotation(CGFloat(-M_PI_2), 0.0, 0.0, 1.0),
                CATransform3DMakeScale(1.5, 1.5, 1.5)
            )
            blueSquare.layer.cornerRadius = 50.0
            blueSquare.layer.borderWidth = 0
            
        }, completion: nil).animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.33, initialSpringVelocity: 0.0, options: .Repeat,
            animations: {
                
                //spring animate the view
                redSquare.transform = CGAffineTransformIdentity
                
                //spring animate the layer
                blueSquare.layer.transform = CATransform3DIdentity
                blueSquare.layer.cornerRadius = 0.0
                blueSquare.layer.borderWidth = 2
                
            }, completion: nil)
}

//MARK: Animate
animate()

let playground = XCPlaygroundPage.currentPage
playground.liveView = containerView

