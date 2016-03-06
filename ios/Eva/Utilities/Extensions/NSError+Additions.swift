//
//  NSError+Additions.swift
//  Eva
//
//  Created by Francisco Díaz on 3/5/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

import Foundation

internal extension NSError {
    private struct Constants {
        static let ErrorDomain = "com.axiomzen.talera"
        static let UnknownErrorCode: Int = 0
        static let AuthErrorCode: Int = 1
        static let ImageProcessingErrorCode: Int = 2
        static let ParsingErrorCode: Int = 3
    }
    static func defaultError() -> NSError {
        return NSError(domain: Constants.ErrorDomain, code: Constants.UnknownErrorCode, userInfo: [NSLocalizedDescriptionKey: "Something went wrong."])
    }
    
    static func authError() -> NSError {
        return NSError(domain: Constants.ErrorDomain, code: Constants.AuthErrorCode, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated."])
    }
    
    static func imageProcessingError() -> NSError {
        return NSError(domain: Constants.ErrorDomain, code: Constants.ImageProcessingErrorCode, userInfo: [NSLocalizedDescriptionKey: "We couldnt' process the image correctly."])
    }
    
    static func parsingError() -> NSError {
        return NSError(domain: Constants.ErrorDomain, code: Constants.ParsingErrorCode, userInfo: [NSLocalizedDescriptionKey: "We couldnt' parse the response correctly."])
    }
}
