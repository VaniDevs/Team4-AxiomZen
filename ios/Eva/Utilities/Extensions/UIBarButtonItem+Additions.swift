//
//  UIBarButtonItem+Additions.swift
//  Eva
//
//  Created by Camilo Vera Bezmalinovic on 3/5/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

import UIKit

internal extension UIBarButtonItem {
    static func profileItem(target target: AnyObject?, action: Selector) -> UIBarButtonItem {
        let image = UIImage(named: "profile.icon")
        return UIBarButtonItem(image: image, style: .Plain, target: target, action: action)
    }
    
    static func closeItem(target target: AnyObject?, action: Selector) -> UIBarButtonItem {
        let image = UIImage(named: "close.icon")
        return UIBarButtonItem(image: image, style: .Plain, target: target, action: action)
    }
    
    var position: CGPoint {
        return  (valueForKey("view") as? UIView)?.center ?? CGPoint.zero
    }
}


