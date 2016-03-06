//
//  VerifyPhoneInteractor.swift
//  Eva
//
//  Created by Francisco Díaz on 3/5/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

import Foundation

internal protocol VerifyPhoneInteractorType {
    func verifyPhone(withCodeNumber number: String, token: String,
        onSuccess: () -> Void, onFailure: NSError -> Void)
}

internal struct VerifyPhoneInteractor: VerifyPhoneInteractorType {
    private let dataManager: ModelDataManager
    
    init(dataManager: ModelDataManager = ModelDataManager.defaultManager()) {
        self.dataManager = dataManager
    }
    
    func verifyPhone(withCodeNumber number: String, token: String,
        onSuccess: () -> Void, onFailure: NSError -> Void)
    {
        dataManager.verifyPhone(withCodeNumber: number, token: token) { result in
            switch result {
            case .Success(let value):
                guard let authToken = value["token"] as? String,
                    user = value["user"] as? JSONDictionary,
                    userId = user["id"] as? Int else
                {
                    onFailure(NSError.defaultError())
                    return
                }
                Persistence.setAuthToken(authToken)
                Persistence.setUserId(userId)
                onSuccess()
            case .Failure(let error):
                onFailure(error)
            }
        }
    }
}
