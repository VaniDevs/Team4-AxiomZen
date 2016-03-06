//
//  SignUpInteractor.swift
//  Eva
//
//  Created by Francisco Díaz on 3/5/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

import Foundation

internal protocol SignUpInteractorType {
    func signUp(withPhoneNumber number: String, onSuccess: (token: String) -> Void, onFailure: NSError -> Void)
}

internal struct SignUpInteractor: SignUpInteractorType {
    private let dataManager: ModelDataManager
    
    init(dataManager: ModelDataManager = ModelDataManager.defaultManager()) {
        self.dataManager = dataManager
    }
    
    func signUp(withPhoneNumber number: String, onSuccess: (token: String) -> Void, onFailure: NSError -> Void) {
        dataManager.signUp(withPhoneNumber: number) { result in
            switch result {
            case .Success(let value):
                guard let token = value["token"] as? String else {
                    onFailure(NSError.defaultError())
                    return
                }
                onSuccess(token: token)
            case .Failure(let error):
                onFailure(error)
            }
        }
    }
}
