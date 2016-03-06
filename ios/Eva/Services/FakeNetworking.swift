//
//  FakeNetworking.swift
//  Eva
//
//  Created by Francisco Díaz on 3/5/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

import Alamofire

internal struct FakeAPI: APIType {
    func signUp(withPhoneNumber phoneNumber: String, completion: Result<JSONDictionary, NSError> -> Void) {
        var fakeJSON = JSONDictionary()
        fakeJSON["token"] = "9281289319289312-fake"
        completion(.Success(fakeJSON))
    }
    
    func verifyCode(codeNumber codeNumber: String, token: String, completion: Result<JSONDictionary, NSError> -> Void) {
        var fakeJSON = JSONDictionary()
        fakeJSON["user"] = ["id": 1234123]
        fakeJSON["token"] = "awejaiowej29002132ijori-fake"
        completion(.Success(fakeJSON))
    }
    
    func createReport(withUserId userId: Int, latitude: Double, longitude: Double, completion: Result<JSONDictionary, NSError> -> Void) {
        completion(.Success(JSONDictionary()))
    }
    
    func cancelLastReport(completion: Result<JSONDictionary, NSError> -> Void) {
        completion(.Success(JSONDictionary()))
    }
    
    func linkImage(toReportId reportId: Int, imageData: NSData, completion: Result<JSONDictionary, NSError> -> Void) {
        completion(.Success([:]))
    }
    
    func linkLocation(toReportId reportId: Int, latitude: Double, longitude: Double, completion: Result<JSONDictionary, NSError> -> Void) {
        completion(.Success([:]))
    }
    
    func uploadAvatarImage(withUserId userId: Int, imageData: NSData, completion: Result<JSONDictionary, NSError> -> Void) {
        var fakeJSON = JSONDictionary()
        fakeJSON["URL"] = "http://i164.photobucket.com/albums/u8/hemi1hemi/COLOR/COL9-6.jpg"
        completion(.Success(fakeJSON))
    }
    
    func uploadContextImage(withUserId userId: Int, imageData: NSData, completion: Result<JSONDictionary, NSError> -> Void) {
        var fakeJSON = JSONDictionary()
        fakeJSON["URL"] = "http://i164.photobucket.com/albums/u8/hemi1hemi/COLOR/COL9-6.jpg"
        completion(.Success(fakeJSON))
    }
    
    func getUser(forUserId userId: Int, completion: Result<JSONDictionary, NSError> -> Void) {
        var fakeJSON = JSONDictionary()
        fakeJSON["contextImages"] = [
            "http://i164.photobucket.com/albums/u8/hemi1hemi/COLOR/COL9-6.jpg",
            "https://www.ucl.ac.uk/news/news-articles/1213/muscle-fibres-heart.jpg",
            "http://snappa.static.pressassociation.io/assets/2015/07/06141424/1436188463-925b981a4c21bfedd7044fb16d7101d7-600x449.jpg",
            "http://www.adobe.com/content/dam/acom/en/products/elements-family/images/pse-transform-photos-butterfly-288x1702-retina.jpg",
            "http://cheesycam.com/wp-content/uploads/2012/12/GH3-Photos-100.jpg",
            "http://www.letsgodigital.org/images/producten/1776/testrapport/nikon-d60-photos.jpg",
            "http://language.chinadaily.com.cn/images/attachement/jpg/site1/20151113/0023ae98988b17afa42f36.jpg"
        ]
        completion(.Success(fakeJSON))
    }
    
    func updateProfile(withName name: String?, context: String?, completionHandler completion: Result<JSONDictionary, NSError> -> Void) {
        var fakeJSON = JSONDictionary()
        var user = JSONDictionary()
        if name != nil {
            user["name"] = name
        }
        if context != nil {
            user["context"] = context
        }
        fakeJSON["user"] = user
        completion(.Success(fakeJSON))
    }
}
