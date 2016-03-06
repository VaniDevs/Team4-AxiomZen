//
//  UIImageView+Additions.swift
//  Eva
//
//  Created by Camilo Vera Bezmalinovic on 3/6/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

private struct SecureRequest: URLRequestConvertible {
    let URL: NSURL
    
    var URLRequest: NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: URL)
        API.secureRequest(request)
        return request
    }
}

extension UIImageView {
    func setSecureImage(withURL URL: NSURL, completion: (Response<UIImage, NSError> -> Void)? = nil) {
        let request = SecureRequest(URL: URL)
        af_setImageWithURLRequest(request, completion: completion)
    }
    
    func cancelImageRequest() {
        af_cancelImageRequest()
    }
}

extension UIButton {
    func setSecureImage(withURL URL: NSURL, completion: (Response<UIImage, NSError> -> Void)? = nil) {
        let request = SecureRequest(URL: URL)
        af_setBackgroundImageForState(.Normal, URLRequest: request, completion: completion)
    }
    
    func cancelImageRequest() {
        af_cancelBackgroundImageRequestForState(.Normal)
    }
}
