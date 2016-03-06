//
//  Persistence.swift
//  Eva
//
//  Created by Francisco Díaz on 3/5/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

import Foundation



internal struct Persistence {
    private struct Constants {
        static let suitName = "group.co.axiomzen.Eva"
        static let authToken = "co.axiomzen.eva.authtoken"
        static let userId = "co.axiomzen.eva.userId"
        static let reporting = "co.axiomzen.eva.reporting"
    }
}

private let defaults = NSUserDefaults(suiteName: Persistence.Constants.suitName) ?? NSUserDefaults.standardUserDefaults()

internal extension Persistence {

    static func authToken() -> String? {
        return defaults.stringForKey(Constants.authToken)
    }
    
    static func setAuthToken(authToken: String?) {
        defaults.setValue(authToken, forKey: Constants.authToken)
    }
    
    static func userId() -> Int? {
        return defaults.integerForKey(Constants.userId)
    }
    
    static func setUserId(userId: Int?) {
        if let ID = userId {
            defaults.setInteger(ID, forKey: Constants.userId)
        } else {
            defaults.removeObjectForKey(Constants.userId)
        }
    }
    
    static var reporting: Bool {
        set {
            defaults.setBool(newValue, forKey: Constants.reporting)
            defaults.synchronize()
        }
        get {
            return defaults.boolForKey(Constants.reporting)
        }
    }
    
    static func saveCurrentUser(user: User) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(user)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "currentUser")

    }
    
    static func currentUser() -> User? {
        guard let data = NSUserDefaults.standardUserDefaults().objectForKey("currentUser") as? NSData else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? User
    }
    
    static func resetCredentials() {
        setAuthToken(nil)
        setUserId(nil)
        reporting = false
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "currentUser")
    }
}
