//: Multiple Animation

import Foundation
import UIKit
import XCPlayground


func delay(seconds seconds: Double, completion:()->()) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
    
    dispatch_after(popTime, dispatch_get_main_queue()) {
        completion()
    }
}

//: Views Setup
var viewCount: Int = 0
let maxViews: Int = 190


let containerRect = CGRectMake(0, 0, 400, 800)
let containerView = UIView(frame: containerRect)
containerView.backgroundColor = UIColor.whiteColor()

let countLabel: UILabel = UILabel(frame: CGRectMake(170,50,200,50))
containerView.addSubview(countLabel)


let playground = XCPlaygroundPage.currentPage
playground.liveView = containerView



//: Animation
func spawn() {
    viewCount++
    if viewCount > maxViews {
        return
    }
    
    let v = UIView(frame: CGRect(x: 50, y: 100, width: 100, height: 100))
    v.backgroundColor = UIColor(hue: CGFloat(Double(containerView.subviews.count)/Double(maxViews)), saturation: 1.0, brightness: 1.0, alpha: 1.0)
    v.layer.cornerRadius = 50.0
    containerView.addSubview(v)
    
    let duration = 5.0
    
    UIView.animateAndChainWithDuration(duration, delay: 0.0, options: [], animations: {
        v.center.y += 250.0
        }, completion: nil).animateWithDuration(duration, animations: {
            v.center.x += 200.0
        }).animateWithDuration(duration, animations: {
            v.center.y -= 250.0
        }).animateWithDuration(duration, delay: 0.0, options: .Repeat, animations: {
            v.center.x -= 200.0
            }, completion: nil)
    
    countLabel.text = "\(viewCount) views"
    
    delay(seconds: 0.10, completion: {
        spawn()
    })
}


//MARK: Animate
spawn()
