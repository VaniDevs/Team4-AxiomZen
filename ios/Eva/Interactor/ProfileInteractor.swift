//
//  ProfileInteractors.swift
//  Eva
//
//  Created by Francisco Díaz on 3/5/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

import UIKit

internal protocol ProfileInteractorType {
    func uploadAvatarImage(image: UIImage, onSuccess: NSURL -> Void, onFailure: NSError -> Void)
    func uploadContextImage(image: UIImage, onSuccess: NSURL -> Void, onFailure: NSError -> Void)
    func getUser(onSuccess: (user: User, urls: [NSURL]) -> Void, onFailure: NSError -> Void)
    func signout()
    func updateProfile(withName name: String?, context: String?,
        onSuccess: (name: String?, context: String?) -> Void, onFailure: NSError -> Void)
}

internal struct ProfileInteractor: ProfileInteractorType {
    private struct Constants {
        static let compressionQuality: CGFloat = 0.5
    }
    private let dataManager: ModelDataManager
    
    init(dataManager: ModelDataManager = ModelDataManager.defaultManager()) {
        self.dataManager = dataManager
    }
    
    func uploadAvatarImage(image: UIImage, onSuccess: NSURL -> Void, onFailure: NSError -> Void) {
        guard let userId = Persistence.userId() else { onFailure(NSError.authError()); return }
        guard let imageData = UIImageJPEGRepresentation(image, Constants.compressionQuality) else {
            onFailure(NSError.imageProcessingError())
            return
        }
        let oldUser = Persistence.currentUser()
        dataManager.uploadAvatarImage(withUserId: userId, imageData: imageData) { result in
            switch result {
            case .Success(let dictionary):
                guard let filename = dictionary["file"] as? String, URL = self.imageURL(withFilename: filename) else {
                    onFailure(NSError.imageProcessingError())
                    return
                }
                let user = User(id: userId, name: oldUser?.name, context: oldUser?.context, avatarURL: URL)
                Persistence.saveCurrentUser(user)
                onSuccess(URL)
            case .Failure(let error):
                onFailure(error)
            }
        }
    }
    
    func uploadContextImage(image: UIImage, onSuccess: NSURL -> Void, onFailure: NSError -> Void) {
        guard let userId = Persistence.userId() else { onFailure(NSError.authError()); return }
        guard let imageData = UIImageJPEGRepresentation(image, Constants.compressionQuality) else {
            onFailure(NSError.imageProcessingError())
            return
        }
        dataManager.uploadContextImage(withUserId: userId, imageData: imageData) { result in
            switch result {
            case .Success(let dictionary):
                guard let filename = dictionary["file"] as? String, URL = self.imageURL(withFilename: filename) else {
                    onFailure(NSError.imageProcessingError())
                    return
                }
                onSuccess(URL)
            case .Failure(let error):
                onFailure(error)
            }
        }
    }
    
    private func imageURL(withFilename filename: String) -> NSURL? {
        return NSURL(string: EnvironmentConstants.imageURL + filename)
    }
    
    func getUser(onSuccess: (user: User, urls: [NSURL]) -> Void, onFailure: NSError -> Void) {
        guard let userId = Persistence.userId() else { onFailure(NSError.authError()); return }
        
        if let oldUser = Persistence.currentUser() {
            onSuccess(user: oldUser, urls: [])
        }
        
        dataManager.getUser(forUserId: userId) { result in
            switch result {
            case .Success(let dictionary):
                var avatarURL: NSURL?
                var urls: [NSURL] = []
                if let context = dictionary["context"] as? JSONDictionary, imageURLS = context["images"] as? [String] {
                    urls = imageURLS.flatMap { self.imageURL(withFilename: $0) }
                }
                if let avatarFile = dictionary["avatar"] as? String {
                    avatarURL = self.imageURL(withFilename: avatarFile)
                }
                let name = dictionary["name"] as? String
                let context = dictionary["description"] as? String
                let user = User(id: userId, name: name, context: context, avatarURL: avatarURL)
                Persistence.saveCurrentUser(user)
                onSuccess(user: user, urls: urls)
            case .Failure(let error):
                onFailure(error)
            }
        }
    }
    
    func updateProfile(withName name: String?, context: String?, onSuccess: (name: String?, context: String?) -> Void, onFailure: NSError -> Void) {
        guard let userId = Persistence.userId() else { onFailure(NSError.authError()); return }
        let oldUser = Persistence.currentUser()
        dataManager.updateProfile(withName: name, context: context) { result in
            switch result {
            case .Success(let user):
                let name = user["name"] as? String
                let context = user["context"] as? String
                let user = User(id: userId, name: name, context: context, avatarURL: oldUser?.avatarURL)
                Persistence.saveCurrentUser(user)
                onSuccess(name: name, context: context)
            case .Failure(let error):
                onFailure(error)
            }
        }
    }
    
    func signout() {
        Persistence.resetCredentials()
    }
}
