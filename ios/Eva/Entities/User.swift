//
//  User.swift
//  Eva
//
//  Created by Francisco Díaz on 3/6/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

import Foundation

internal final class User: NSObject, NSCoding {
    let id: Int
    var name: String?
    var context: String?
    var avatarURL: NSURL?
    
    init(id: Int, name: String? = nil, context: String? = nil, avatarURL: NSURL? = nil) {
        self.id = id
        self.name = name
        self.context = context
        self.avatarURL = avatarURL
    }
    
    //MARK: - NSCoding
    convenience init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObjectForKey("id") as? Int else { return nil }
        let name = aDecoder.decodeObjectForKey("name") as? String
        let context = aDecoder.decodeObjectForKey("context") as? String
        let avatarURL = aDecoder.decodeObjectForKey("avatarURL") as? NSURL
        self.init(id: id, name: name, context: context, avatarURL: avatarURL)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(context, forKey: "context")
        aCoder.encodeObject(avatarURL, forKey: "avatarURL")
    }
}
