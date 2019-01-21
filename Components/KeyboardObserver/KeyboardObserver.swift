//
//  KeyboardObserver.swift
//  VetChat
//
//  Created by Mark Zhuikov on 11/14/18.
//  Copyright © 2018 SIA Mystic Moments. All rights reserved.
//

import Foundation
import UIKit

struct KeyboardObserverInfo {
    let beginKeyboardRect: CGRect
    let endKeyboardRect: CGRect

    let duration: TimeInterval
    let animationOptions: UIView.AnimationOptions
    let localUser: Bool

    var keyboardBounds: CGRect {
        return CGRect(x: 0, y: 0, width: endKeyboardRect.size.width, height: endKeyboardRect.size.height)
    }

    var keyboardCenterBegin: CGPoint {
        return CGPoint(x: beginKeyboardRect.midX, y: beginKeyboardRect.midY)
    }

    var keyboardCenterEnd: CGPoint {
        return CGPoint(x: endKeyboardRect.midX, y: endKeyboardRect.midY)
    }

    init(beginKeyboardRect: CGRect, endKeyboardRect: CGRect, duration: TimeInterval, animationOptions: UIView.AnimationOptions, localUser: Bool) {
        self.beginKeyboardRect = beginKeyboardRect
        self.endKeyboardRect = endKeyboardRect
        self.duration = duration
        self.animationOptions = animationOptions
        self.localUser = localUser
    }
}

class KeyboardObserver {
    var keyboardWillShow: ((_ info: KeyboardObserverInfo) -> Void)? {
        didSet {
            if keyboardWillShow != nil {
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
            } else {
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            }
        }
    }

    var keyboardDidShow: ((_ info: KeyboardObserverInfo) -> Void)? {
        didSet {
            if keyboardDidShow != nil {
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShowNotification), name: UIResponder.keyboardDidShowNotification, object: nil)
            } else {
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
            }
        }
    }

    var keyboardWillHide: ((_ info: KeyboardObserverInfo) -> Void)? {
        didSet {
            if keyboardWillShow != nil {
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
            } else {
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            }
        }
    }

    var keyboardDidHide: ((_ info: KeyboardObserverInfo) -> Void)? {
        didSet {
            if keyboardDidHide != nil {
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHideNotification), name: UIResponder.keyboardDidHideNotification, object: nil)
            } else {
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
            }
        }
    }

    var keyboardWillChangeFrame: ((_ info: KeyboardObserverInfo) -> Void)? {
        didSet {
            if keyboardWillChangeFrame != nil {
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrameNotification), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            } else {
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            }
        }
    }

    var keyboardDidChangeFrame: ((_ info: KeyboardObserverInfo) -> Void)? {
        didSet {
            if keyboardDidChangeFrame != nil {
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrameNotification), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
            } else {
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
            }
        }
    }

    @objc private func keyboardWillShowNotification(notification: Notification) {
        if keyboardWillShow != nil {
            keyboardWillShow!(keyboardObserverInfoFromDictionary(userInfo: notification.userInfo!))
        }
    }

    @objc private func keyboardDidShowNotification(notification: Notification) {
        if keyboardDidShow != nil {
            keyboardDidShow!(keyboardObserverInfoFromDictionary(userInfo: notification.userInfo!))
        }
    }

    @objc private func keyboardWillHideNotification(notification: Notification) {
        if keyboardWillHide != nil {
            keyboardWillHide!(keyboardObserverInfoFromDictionary(userInfo: notification.userInfo!))
        }
    }

    @objc private func keyboardDidHideNotification(notification: Notification) {
        if keyboardDidHide != nil {
            keyboardDidHide!(keyboardObserverInfoFromDictionary(userInfo: notification.userInfo!))
        }
    }

    @objc private func keyboardWillChangeFrameNotification(notification: Notification) {
        if keyboardWillChangeFrame != nil {
            keyboardWillChangeFrame!(keyboardObserverInfoFromDictionary(userInfo: notification.userInfo!))
        }
    }

    @objc private func keyboardDidChangeFrameNotification(notification: Notification) {
        if keyboardDidChangeFrame != nil {
            keyboardDidChangeFrame!(keyboardObserverInfoFromDictionary(userInfo: notification.userInfo!))
        }
    }

    private func keyboardObserverInfoFromDictionary(userInfo: [AnyHashable: Any]) -> KeyboardObserverInfo {
        let beginKeyboardRect = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! CGRect
        let endKeyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let animationsOptionsValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UIView.AnimationOptions.RawValue
        let localUser: Bool = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] != nil)

        return KeyboardObserverInfo(beginKeyboardRect: beginKeyboardRect,
                                    endKeyboardRect: endKeyboardRect,
                                    duration: duration,
                                    animationOptions: UIView.AnimationOptions(rawValue: animationsOptionsValue),
                                    localUser: localUser)
    }
}
