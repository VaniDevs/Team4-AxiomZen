//
//  ModelDataManager.swift
//  Eva
//
//  Created by Francisco Díaz on 3/5/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

import Alamofire

internal struct ModelDataManager {
    let APIClient: APIType
    
    init(API: APIType) {
        self.APIClient = API
    }
    
    static func defaultManager() -> ModelDataManager {
        let APIClient = API(sessionToken: Persistence.authToken() ?? "")
        return ModelDataManager(API: APIClient)
    }
    
    static func fakeManager() -> ModelDataManager {
        let APIClient = FakeAPI()
        return ModelDataManager(API: APIClient)
    }
}

extension ModelDataManager {
    func signUp(withPhoneNumber number: String, completionHandler completion: Result<JSONDictionary, NSError> -> Void) {
        APIClient.signUp(withPhoneNumber: number, completion: completion)
    }
    
    func verifyPhone(withCodeNumber number: String, token: String, completionHandler completion: Result<JSONDictionary, NSError> -> Void) {
        APIClient.verifyCode(codeNumber: number, token: token, completion: completion)
    }
    
    func createReport(withUserId userId: Int, latitude: Double, longitude: Double, completionHandler completion: Result<JSONDictionary, NSError> -> Void) {
        APIClient.createReport(withUserId: userId, latitude: latitude, longitude: longitude, completion: completion)
    }
    
    func cancelLastReport(completion: Result<JSONDictionary, NSError> -> Void) {
        APIClient.cancelLastReport(completion)
    }
    
    func linkImage(toReportId reportId: Int, imageData: NSData, completionHandler completion: Result<JSONDictionary, NSError> -> Void) {
        APIClient.linkImage(toReportId: reportId, imageData: imageData, completion: completion)
    }
    
    func linkLocation(toReportId reportId: Int, latitude: Double, longitude: Double, completionHandler completion: Result<JSONDictionary, NSError> -> Void) {
        APIClient.linkLocation(toReportId: reportId, latitude: latitude, longitude: longitude, completion: completion)
    }
    
    func uploadAvatarImage(withUserId userId: Int, imageData: NSData, completionHandler completion: Result<JSONDictionary, NSError> -> Void) {
        APIClient.uploadAvatarImage(withUserId: userId, imageData: imageData, completion: completion)
    }
    
    func uploadContextImage(withUserId userId: Int, imageData: NSData, completionHandler completion: Result<JSONDictionary, NSError> -> Void) {
        APIClient.uploadContextImage(withUserId: userId, imageData: imageData, completion: completion)
    }
    
    func getUser(forUserId userId: Int, completionHandler completion: Result<JSONDictionary, NSError> -> Void) {
        APIClient.getUser(forUserId: userId, completion: completion)
    }
    
    func updateProfile(withName name: String?, context: String?, completionHandler completion: Result<JSONDictionary, NSError> -> Void) {
        APIClient.updateProfile(withName: name, context: context, completionHandler: completion)
    }
}
