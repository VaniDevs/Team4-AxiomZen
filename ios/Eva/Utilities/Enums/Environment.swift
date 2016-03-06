//
//  Environment.swift
//  Eva
//
//  Created by Francisco Díaz on 3/5/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

internal struct EnvironmentConstants {
    static var currentEnvironment: Environment {
        return Environment.current
    }
    
    static var imageURL: String {
        switch Environment.current {
        case .Staging: return "http://90888a61.ngrok.io/api/img/"
        case .Production: return "http://90888a61.ngrok.io/api/img/"
        }
    }
    
    static var baseURL: String {
        switch Environment.current {
        case .Staging: return "http://90888a61.ngrok.io/api/v1"
        case .Production: return "http://90888a61.ngrok.io/api/v1"
        }
    }
}

internal enum Environment {
    case Staging
    case Production
    
    #if DEBUG
    private static let current: Environment = .Staging
    #else
    private static let current: Environment = .Production
    #endif
}
