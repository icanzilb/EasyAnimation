//
//  AppDelegate.swift
//  DemoApp
//
//  Created by Marin Todorov on 4/13/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

func delay(seconds: Double, completion:@escaping () -> Void) {
    let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: popTime, execute: completion)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}
