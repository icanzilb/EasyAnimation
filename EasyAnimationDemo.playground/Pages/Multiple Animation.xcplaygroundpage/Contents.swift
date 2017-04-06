//: Multiple Animation

import Foundation
import UIKit
import XCPlayground
import PlaygroundSupport

func delay(seconds: Double, completion:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: {
        completion()
    })
}

//: Views Setup
var viewCount: Int = 0
let maxViews: Int = 190

let containerRect = CGRect(x: 0,y: 0,width: 400,height: 800)
let containerView = UIView(frame: containerRect)
containerView.backgroundColor = UIColor.white

let countLabel: UILabel = UILabel(frame: CGRect(x: 170,y: 50,width: 200,height: 50))
containerView.addSubview(countLabel)

PlaygroundPage.current.liveView = containerView

//: Animation
func spawn() {
    viewCount += 1
    if viewCount > maxViews {
        return
    }
    
    let v = UIView(frame: CGRect(x: 50, y: 100, width: 100, height: 100))
    v.backgroundColor = UIColor(hue: CGFloat(Double(containerView.subviews.count)/Double(maxViews)), saturation: 1.0, brightness: 1.0, alpha: 1.0)
    v.layer.cornerRadius = 50.0
    containerView.addSubview(v)
    
    let duration = 5.0
    UIView.animateAndChain(withDuration: duration, delay: 0.0, options: [], animations: { 
        v.center.y += 250.0
    }, completion: nil).animate(withDuration: duration) {
        v.center.x += 200.0
    }.animate(withDuration: duration) {
        v.center.y -= 250.0
    }.animate(withDuration: duration, delay: 0.0, options: .repeat, animations: { 
        v.center.x -= 200.0
    }, completion: nil)
  
    countLabel.text = "\(viewCount) views"
    
    delay(seconds: 0.10, completion: {
        spawn()
    })
}


//MARK: Animate
spawn()
