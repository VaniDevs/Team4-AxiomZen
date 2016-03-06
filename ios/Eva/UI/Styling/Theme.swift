//
//  Theme.swift
//  Eva
//
//  Created by Camilo Vera Bezmalinovic on 3/5/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

import UIKit

internal struct Theme {
    static func setDefaultTheme() {
        UIView.appearance().tintColor = Color.report
        UINavigationBar.appearance().tintColor = Color.white
        UINavigationBar.appearance().barTintColor = Color.report
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().barStyle = .Black
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
}