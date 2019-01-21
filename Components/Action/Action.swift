//
//  Action.swift
//  Put Capital
//
//  Created by Vitali Kurlovich on 4/9/18.
//  Copyright © 2018 Vitali Kurlovich. All rights reserved.
//

import UIKit

protocol ActionProtocol {
    func performAction()
}

class Action: ActionProtocol {
    private let action: ((_ action: Action) -> Void)?
    let title: String?
    let image: UIImage?

    convenience init(title: String, _ action: ((_ action: Action) -> Void)?) {
        self.init(title: title, image: nil, action)
    }

    convenience init(image: UIImage, _ action: ((_ action: Action) -> Void)?) {
        self.init(title: nil, image: image, action)
    }

    init(title: String?, image: UIImage?, _ action: ((_ action: Action) -> Void)?) {
        self.action = action
        self.title = title
        self.image = image
    }

    func performAction() {
        if action != nil {
            action!(self)
        }
    }
}

class EditValueAction<T>: ActionProtocol {
    let title: String?
    let description: String?

    private let action: ((_ action: EditValueAction<T>) -> Void)?

    init(title: String? = nil,
         description: String? = nil,
         value: T? = nil,
         _ action: ((_ action: EditValueAction<T>) -> Void)? = nil) {
        self.action = action
        self.title = title
        self.description = description
        self.value = value
    }

    var value: T? {
        didSet {
            performAction()
        }
    }

    func performAction() {
        if action != nil {
            action!(self)
        }
    }
}
