//
//  String+Additions.swift
//  Eva
//
//  Created by Francisco Díaz on 3/5/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

internal extension String {
    func localize(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
}
