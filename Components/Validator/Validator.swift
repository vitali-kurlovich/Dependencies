//
//  Validator.swift
//  Put Capital
//
//  Created by Vitali Kurlovich on 4/28/18.
//  Copyright © 2018 Vitali Kurlovich. All rights reserved.
//

import Foundation

protocol Validator {
    func validate(_ obj: Any?) -> Bool
}
