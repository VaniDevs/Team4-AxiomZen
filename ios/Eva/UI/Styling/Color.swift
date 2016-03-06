//
//  Color.swift
//  Eva
//
//  Created by Camilo Vera Bezmalinovic on 3/5/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

import UIKit

struct Color {
    static var report: UIColor { return Persistence.reporting ? okColor : helpColor }
    static let helpColor = Color.color(withHex: 0xa02323)
    static let okColor = Color.color(withHex: 0x5a7a2e)
    static let blue = Color.color(withHex: 0x1F5B87)
    static let orange = Color.color(withHex: 0xFFB87E)
    static let red = Color.color(withHex: 0xFF6B6E)
    static let green = Color.color(withHex: 0xB8D175)
    static let turquoise = Color.color(withHex: 0x00DADB)
    static let white = Color.color(withHex: 0xFFFFFF)
    
    private static func colorWithRGBA(red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: (red/255), green: (green/255), blue: (blue/255), alpha: (alpha/1))
    }
    
    private static func color(withHex hex: UInt32, alpha: CGFloat = 1) -> UIColor {
        return colorWithRGBA(CGFloat((hex & 0xFF0000) >> 16), CGFloat((hex & 0xFF00) >> 8), CGFloat(hex & 0xFF), alpha)
    }
}