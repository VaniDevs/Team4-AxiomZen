//
//  EmergencyButton.swift
//  Eva
//
//  Created by Camilo Vera Bezmalinovic on 3/5/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

import UIKit


internal final class EmergencyButton: Button {
    struct Constants {
        static let backgroundColor = Color.red
        static let fontSize: CGFloat = 40
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        titleLabel?.font = UIFont.boldSystemFontOfSize(Constants.fontSize)
        layer.cornerRadius = bounds.midY
        backgroundColor = Constants.backgroundColor
    }
    
    override var highlighted: Bool {
        didSet {
            guard highlighted else {
                transform = CGAffineTransformIdentity
                return
            }
            transform = CGAffineTransformMakeTranslation(layer.shadowOffset.width, layer.shadowOffset.height)
        }
    }

}
