//
//  AppDelegate.swift
//  DemoApp
//
//  Created by Marin Todorov on 4/13/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

func delay(seconds: Double, completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    EasyAnimation.enable()
    return true
  }
}
