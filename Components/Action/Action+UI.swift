//
//  Action+UI.swift
//  VetChat
//
//  Created by Vitali Kurlovich on 10/9/18.
//  Copyright © 2018 SIA Mystic Moments. All rights reserved.
//

import ObjectiveC
import UIKit

private var AssociatedButtonActionHandle: UInt8 = 0

extension UIButton {
    var action: Action? {
        get {
            return objc_getAssociatedObject(self, &AssociatedButtonActionHandle) as? Action
        }

        set(action) {
            objc_setAssociatedObject(self, &AssociatedButtonActionHandle, action, .OBJC_ASSOCIATION_RETAIN)
            update(with: action)
        }
    }

    fileprivate
    func update(with action: Action?) {
        setTitle(action?.title, for: .normal)
        setImage(action?.image, for: .normal)

        if action == nil {
            removeTarget(self, action: #selector(onClick(_:)), for: .primaryActionTriggered)
        } else {
            addTarget(self, action: #selector(onClick(_:)), for: .primaryActionTriggered)
        }
    }

    @objc fileprivate
    func onClick(_: Button) {
        action?.performAction()
    }
}

private var AssociatedSegmentedControlActionsHandle: UInt8 = 0

extension UISegmentedControl {
    var actions: [Action]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedSegmentedControlActionsHandle) as? [Action]
        }

        set(actions) {
            objc_setAssociatedObject(self, &AssociatedSegmentedControlActionsHandle, actions, .OBJC_ASSOCIATION_COPY)
            // update(with: action)
        }
    }
}
