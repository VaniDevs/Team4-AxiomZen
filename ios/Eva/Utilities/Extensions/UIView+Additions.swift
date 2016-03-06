//
//  UIView+Additions.swift
//  Eva
//
//  Created by Camilo Vera Bezmalinovic on 3/5/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

import UIKit

extension UIView {
    func addDefaultMotionEffect() {
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -10
        vertical.maximumRelativeValue = 10
        
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -10
        horizontal.maximumRelativeValue = 10
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [vertical, horizontal]
        addMotionEffect(group)
    }
}
