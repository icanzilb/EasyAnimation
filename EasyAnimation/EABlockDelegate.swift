//
//  EABlockDelegate.swift
//  DemoApp
//
//  Created by Marin Todorov on 5/30/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

class EABlockDelegate: NSObject {
    
    var didStop: ((anim: CAAnimation!, finished: Bool)->Void)?
    init(didStop: (anim: CAAnimation!, finished: Bool)->Void) {
        self.didStop = didStop
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        didStop?(anim: anim, finished: flag)
    }
    deinit {
        println("delegate died")
    }
}
