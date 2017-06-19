
//: Spring Animation

import Foundation
import UIKit
import XCPlayground
import PlaygroundSupport


let containerRect = CGRect(x: 0,y: 0,width: 400,height: 800)
let containerView = UIView(frame: containerRect)
containerView.backgroundColor = UIColor.white

PlaygroundPage.current.liveView = containerView



let redSquare: UIView = UIView(frame: CGRect(x:50,y:50,width:100,height:100))
    redSquare.backgroundColor = UIColor.red
    containerView.addSubview(redSquare)

let blueSquare: UIView = UIView(frame: CGRect(x:250,y:50,width:100,height:100))
    blueSquare.backgroundColor = UIColor.blue
    containerView.addSubview(blueSquare)

    //animate the view and the layer
    UIView.animate(withDuration: 0.33, delay: 0.0, options: [.curveEaseOut, .repeat, .autoreverse],
        animations: { () -> Void in
            
            //view property animation
            redSquare.transform = CGAffineTransform(scaleX: 1.33, y: 1.5).concatenating(
                CGAffineTransform(translationX: 0.0, y: 50.0)
            )
            
            //layer properties animations
            blueSquare.layer.cornerRadius = 30.0
            blueSquare.layer.borderWidth = 10.0
            blueSquare.layer.borderColor = UIColor.blue.cgColor
            blueSquare.layer.shadowColor = UIColor.gray.cgColor
            blueSquare.layer.shadowOffset = CGSize(width: 15.0, height: 15.0)
            blueSquare.layer.shadowOpacity = 0.5
            
            var trans3d = CATransform3DIdentity
            trans3d.m34 = -1.0/500.0
            
            let rotationTransform = CATransform3DRotate(trans3d, CGFloat(-M_PI_4), 0.0, 1.0, 0.0)
            let translationTransform = CATransform3DMakeTranslation(-50.0, 0, 0)
            blueSquare.layer.transform = CATransform3DConcat(rotationTransform, translationTransform)
            
        }, completion: nil)


