//
//  MotionController.swift
//  Eva
//
//  Created by Camilo Vera Bezmalinovic on 3/5/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

import Foundation

internal final class MotionController: NSObject {
    struct Constants {
        static let knocksTimeWindow: NSTimeInterval = 1.0
        static let requieredNumberOfNocks: Int = 3
    }
    
    private let motionController: HTKnockDetector

    private var detectedKnockTime: NSTimeInterval = 0
    private var detectedKnocks: Int = 0
    
    var motionAlertHandler: (() -> Void)?
    
    override init() {
        motionController = HTKnockDetector()
        super.init()
        motionController.delegate = self
        motionController.isOn = true
    }
    
    private func sendAlert() {
        motionAlertHandler?()
    }
}

extension MotionController: HTKnockDetectorDelegate {
    func knockDetectorDetectedKnock(detector: HTKnockDetector!, atTime time: NSTimeInterval) {
        //Do something with the knocsk
        if time > detectedKnockTime + Constants.knocksTimeWindow {
            detectedKnockTime = time
            detectedKnocks = 0
        }
        detectedKnocks += 1
        if detectedKnocks >= Constants.requieredNumberOfNocks {
            sendAlert()
            detectedKnocks = 0
            detectedKnockTime = time
        }
    }
}
