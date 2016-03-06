//
//  UIViewController+Additions.swift
//  Eva
//
//  Created by Camilo Vera Bezmalinovic on 3/5/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

import UIKit

internal protocol KeyboardNotificationsProtocol: class {
    var keyboardObservers: [NSObjectProtocol] { get set }
    func unregisterForKeyboardNotifications()
    func keyboardWillShowNotification(handler: KeyboardNotificationHandler)
    func keyboardWillHideNotification(handler: KeyboardNotificationHandler)
}

typealias KeyboardNotificationHandler = (height: CGFloat, duration: NSTimeInterval, curve: UIViewAnimationOptions) -> Void

extension KeyboardNotificationsProtocol where Self: UIViewController {
    func keyboardWillShowNotification(handler: KeyboardNotificationHandler) {
        addObserver(UIKeyboardWillShowNotification, handler: handler)
    }
    
    func keyboardWillHideNotification(handler: KeyboardNotificationHandler) {
        addObserver(UIKeyboardWillHideNotification, handler: handler)
    }
    
    private func addObserver(name: String, handler: KeyboardNotificationHandler) {
        let nc = NSNotificationCenter.defaultCenter()
        let observer = nc.addObserverForName(name, object: nil, queue: nil) { notification in
            guard let userInfo = notification.userInfo else { return }
            let durationNumber = userInfo[UIKeyboardAnimationDurationUserInfoKey]! as! NSNumber
            let duration: NSTimeInterval = durationNumber.doubleValue
            let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey]! as! NSValue
            let height = CGRectGetHeight(frameValue.CGRectValue())
            let curve = UIViewAnimationOptions(rawValue: (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UInt) << 16)
            handler(height: height, duration: duration, curve: curve)
        }
        keyboardObservers.append(observer)
    }
    
    func unregisterForKeyboardNotifications() {
        let nc = NSNotificationCenter.defaultCenter()
        keyboardObservers.forEach {
            nc.removeObserver($0)
        }
    }
}

internal class MaskTransition: NSObject {
    let presenting: Bool
    let position: CGPoint
    init(presenting: Bool, position: CGPoint) {
        self.presenting = presenting
        self.position = position
    }
}
