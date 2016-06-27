//
//  AppDelegate.swift
//  DemoApp
//
//  Created by Marin Todorov on 4/13/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

func delay(seconds: Double, completion:()->()) {
    let popTime: DispatchTime = DispatchTime.now() + Double(NSEC_PER_SEC) * seconds;

    DispatchQueue.main.after(when: popTime) {
        completion()
    }

}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
}
