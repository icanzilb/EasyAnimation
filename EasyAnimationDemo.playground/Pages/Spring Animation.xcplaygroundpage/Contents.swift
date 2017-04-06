//: Spring Animation

import Foundation
import UIKit
import XCPlayground
import PlaygroundSupport

let containerRect = CGRect(x: 0,y: 0,width: 400,height: 800)
let containerView = UIView(frame: containerRect)
containerView.backgroundColor = UIColor.white


let redSquare = UIView(frame: CGRect(x: 50,y: 100,width: 100,height: 100))
redSquare.backgroundColor = UIColor.red
containerView.addSubview(redSquare)

let blueSquare = UIView(frame: CGRect(x: 250,y: 100,width: 100,height: 100))
blueSquare.backgroundColor = UIColor.blue
blueSquare.layer.borderColor = UIColor(white: 0.2, alpha: 1.0).cgColor
containerView.addSubview(blueSquare)


/// Animation function
func animate() {
    
    UIView.animateAndChain(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.33, initialSpringVelocity: 0.0, options: [], animations: { 
        //spring animate the view
        redSquare.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2)).concatenating(
            CGAffineTransform(scaleX: 1.5, y: 1.5)
        )
        
        //spring animate the layer
        blueSquare.layer.transform = CATransform3DConcat(
            CATransform3DMakeRotation(CGFloat(-M_PI_2), 0.0, 0.0, 1.0),
            CATransform3DMakeScale(1.5, 1.5, 1.5)
        )
        blueSquare.layer.cornerRadius = 50.0
        blueSquare.layer.borderWidth = 0
    }, completion: nil).animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.33, initialSpringVelocity: 0.0, options: .repeat, animations: { 
        
        //spring animate the view
        redSquare.transform = CGAffineTransform.identity
        
        //spring animate the layer
        blueSquare.layer.transform = CATransform3DIdentity
        blueSquare.layer.cornerRadius = 0.0
        blueSquare.layer.borderWidth = 2
    }, completion: nil)
    
}

//MARK: Animate
animate()

PlaygroundPage.current.liveView = containerView


