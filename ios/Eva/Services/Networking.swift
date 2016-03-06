//
//  Networking.swift
//  Eva
//
//  Created by Francisco Díaz on 3/5/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

import Alamofire

// MARK: - API
internal protocol APIType: UnauthenticatedAPIType, AuthenticatedAPIType {}

internal protocol UnauthenticatedAPIType {
    func signUp(withPhoneNumber phoneNumber: String, completion: Result<JSONDictionary, NSError> -> Void)
    func verifyCode(codeNumber codeNumber: String, token: String, completion: Result<JSONDictionary, NSError> -> Void)
}

internal protocol AuthenticatedAPIType {
    func createReport(withUserId userId: Int, latitude: Double, longitude: Double, completion: Result<JSONDictionary, NSError> -> Void)
    func cancelLastReport(completion: Result<JSONDictionary, NSError> -> Void)
    func linkImage(toReportId reportId: Int, imageData: NSData, completion: Result<JSONDictionary, NSError> -> Void)
    func linkLocation(toReportId reportId: Int, latitude: Double, longitude: Double, completion: Result<JSONDictionary, NSError> -> Void)
    func uploadAvatarImage(withUserId userId: Int, imageData: NSData, completion: Result<JSONDictionary, NSError> -> Void)
    func uploadContextImage(withUserId userId: Int, imageData: NSData, completion: Result<JSONDictionary, NSError> -> Void)
    func getUser(forUserId userId: Int, completion: Result<JSONDictionary, NSError> -> Void)
    func updateProfile(withName name: String?, context: String?, completionHandler completion: Result<JSONDictionary, NSError> -> Void)
}

internal struct API: APIType {
    private var manager = APIManager()
    private var sessionToken: String = "" {
        didSet { ensureUnique(sessionToken) }
    }
    
    init(sessionToken: String = "") {
        self.sessionToken = sessionToken
        self.manager = APIManager(sessionToken: sessionToken)
    }
    
    mutating func ensureUnique(sessionToken: String? = nil) {
        if !isUniquelyReferencedNonObjC(&manager) {
            manager = APIManager(sessionToken: sessionToken)
        }
    }
    
    private func request<T>(method: Alamofire.Method, _ URLString: APIRouter,
        parameters: JSONDictionary? = nil, encoding: ParameterEncoding = .JSON,
        validStatusCode: Range<Int> = 200..<300,
        completion: Result<T, NSError> -> Void) -> Alamofire.Request
    {
        return manager.request(method, URLString, parameters: parameters, encoding: encoding)
            .validate(statusCode: validStatusCode)
            .validate(contentType: APIManager.Constants.ContentTypes)
            .responseJSON { response in
                handleResponse(response, completion: completion)
            }
    }


    private func uploadImage(data: NSData, _ URLString: APIRouter,
        completion: Result<JSONDictionary, NSError> -> Void)
    {
        manager.upload(.PUT, URLString, multipartFormData: { multipartFormData in
            multipartFormData.appendBodyPart(data: data, name: "photo", fileName: "image.jpeg", mimeType: "image/jpeg")
            }) { manager in
                switch manager {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        handleResponse(response, completion: completion)
                    }
                case .Failure(let error):
                    completion(.Failure(error as NSError))
                }
                
        }
    }
    
    static func secureRequest(request: NSMutableURLRequest) {
        request.setValue(APIManager.Constants.APITokenValue, forHTTPHeaderField: APIManager.Constants.APIToken)
    }
}

private func handleResponse<T>(response: Response<AnyObject, NSError>,
    completion: Result<T, NSError> -> Void)
{
    if let statusCode = response.response?.statusCode
        where (statusCode == APIManager.Constants.StatusCodes.OK)
            || (statusCode == APIManager.Constants.StatusCodes.NoContent),
        let returnValue = true as? T {
            completion(.Success(returnValue))
            return
    }
    switch response.result {
    case let .Success(value): completion(.Success(value as! T))
    case let .Failure(error): completion(.Failure(APIError(response.response, response.data, error as NSError)))
    }
}


// MARK: - API Extensions

extension API: UnauthenticatedAPIType {
    func signUp(withPhoneNumber phoneNumber: String, completion: Result<JSONDictionary, NSError> -> Void) {
        let parameters = [Keys.Authenticate.phoneNumber: phoneNumber]
        request(.POST, .Authenticate, parameters: parameters, completion: completion)
    }
    
    func verifyCode(codeNumber codeNumber: String, token: String, completion: Result<JSONDictionary, NSError> -> Void) {
        var parameters = JSONDictionary()
        parameters[Keys.Authenticate.code] = codeNumber
        parameters[Keys.Authenticate.token] = token
        request(.POST, .Authenticate, parameters: parameters, completion: completion)
    }
}

extension API: AuthenticatedAPIType {
    func createReport(withUserId userId: Int, latitude: Double, longitude: Double, completion: Result<JSONDictionary, NSError> -> Void) {
        var parameters = JSONDictionary()
        parameters[Keys.Report.latitude] = latitude
        parameters[Keys.Report.longitude] = longitude
        request(.POST, .Report(id: nil), parameters: parameters, completion: completion)
    }
    
    func linkImage(toReportId reportId: Int, imageData: NSData, completion: Result<JSONDictionary, NSError> -> Void) {
        uploadImage(imageData, .Report(id: reportId), completion: completion)
    }
    
    func linkLocation(toReportId reportId: Int, latitude: Double, longitude: Double, completion: Result<JSONDictionary, NSError> -> Void) {
        var parameters = JSONDictionary()
        parameters[Keys.Report.latitude] = latitude
        parameters[Keys.Report.longitude] = longitude
        request(.PUT, .Report(id: reportId), parameters: parameters, completion: completion)
    }
    
    func uploadAvatarImage(withUserId userId: Int, imageData: NSData, completion: Result<JSONDictionary, NSError> -> Void) {
        uploadImage(imageData, .Avatar, completion: completion)
    }
    
    func uploadContextImage(withUserId userId: Int, imageData: NSData, completion: Result<JSONDictionary, NSError> -> Void) {
        uploadImage(imageData, .User, completion: completion)
    }
    
    func getUser(forUserId userId: Int, completion: Result<JSONDictionary, NSError> -> Void) {
        request(.GET, .User, parameters: nil, completion: completion)
    }
    
    func updateProfile(withName name: String?, context: String?, completionHandler completion: Result<JSONDictionary, NSError> -> Void) {
        var parameters = JSONDictionary()
        parameters[Keys.User.name] = name
        parameters[Keys.User.context] = context
        request(.PUT, .User, parameters: parameters, completion: completion)
    }
    
    func cancelLastReport(completion: Result<JSONDictionary, NSError> -> Void) {
        request(.PUT, .FalseAlarmReport, parameters: nil, completion: completion)
    }
}

// MARK: - Router

private enum APIRouter: URLStringConvertible {
    case Authenticate
    case Report(id: Int?)
    case FalseAlarmReport
    case User
    case UserImage(userId: Int)
    case Avatar
    
    var URLString: String {
        let path: String
        switch self {
        case .Authenticate: path = "/authenticate"
        case .Report(.None): path = "/report"
        case .Report(.Some(let id)): path = "/report/\(id)"
        case .FalseAlarmReport: path = "/false_alarm"
        case .User: path = "/user"
        case .UserImage(let id): path = "/user/\(id)/contextimages"
        case .Avatar: path = "/avatar"
        }
        return EnvironmentConstants.baseURL + path
    }
}

// MARK: - APIManager

private final class APIManager: Manager {
    
    private struct Constants {
        static let APIToken = "x-api-token"
        static let APITokenValue = "d0bacab2-e412-4f77-8e5d-3b3c7475a750"
        static let AuthTokenKey = "x-authentication-token"
        static let ContentTypes = ["application/json"]
        static let TimeoutInterval: NSTimeInterval = 30
        struct StatusCodes {
            static let OK: Int = 200
            static let NoContent: Int = 204
        }
    }
    
    private required init(configuration: NSURLSessionConfiguration = .defaultSessionConfiguration()) {
        configuration.timeoutIntervalForRequest = Constants.TimeoutInterval
        configuration.HTTPAdditionalHeaders = APIManager.defaultHTTPHeaders()
        super.init(configuration: configuration)
    }
    
    private init(sessionToken: String?, configuration: NSURLSessionConfiguration = .defaultSessionConfiguration()) {
        configuration.timeoutIntervalForRequest = Constants.TimeoutInterval
        configuration.HTTPAdditionalHeaders = APIManager.defaultHTTPHeaders(sessionToken)
        super.init(configuration: configuration)
    }
    
    override init(configuration: NSURLSessionConfiguration, delegate: Manager.SessionDelegate, serverTrustPolicyManager: ServerTrustPolicyManager?) {
        fatalError("init(configuration:serverTrustPolicyManager:) has not been implemented")
    }
    
    private static func defaultHTTPHeaders(sessionToken: String? = nil) -> [String: String] {
        var headers = Manager.defaultHTTPHeaders
        headers[Constants.APIToken] = Constants.APITokenValue
        headers[Constants.AuthTokenKey] = sessionToken
        return headers
    }
}

private func APIError(response: NSHTTPURLResponse?, _: NSData?, _ error: NSError) -> NSError {
    return NSError(domain: error.domain, code: response?.statusCode ?? error.code, userInfo: nil)
}

private struct DownloadRequest: URLRequestConvertible {
    let URLString: String
    
    init(URLString: String) {
        self.URLString = URLString
    }
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: URLString) ?? NSURL()
        let request = NSMutableURLRequest(URL: URL)
        return request
    }
}

// MARK: - Constants

private struct Keys {
    struct Authenticate {
        static let phoneNumber = "phone"
        static let code = "code"
        static let token = "token"
    }
    
    struct Report {
        static let userId = "userId"
        static let latitude = "lat"
        static let longitude = "lng"
        static let image = "image"
    }
    
    struct User {
        static let userId = "id"
        static let name = "name"
        static let context = "description"
        static let contextImage = "contextImage"
    }
}
