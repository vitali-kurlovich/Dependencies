//
//  StringNumberValidator.swift
//  Put Capital
//
//  Created by Vitali Kurlovich on 5/7/18.
//  Copyright © 2018 Vitali Kurlovich. All rights reserved.
//

import Foundation

struct StringNumberValidator: Validator {
    func validate(_ obj: Any?) -> Bool {
        guard let string = obj as? String, string.count > 0 else {
            return true
        }

        let decimalDigits = CharacterSet.decimalDigits
        let whitespaces = CharacterSet.whitespaces

        let decimalSeparator = UnicodeScalar(Locale.autoupdatingCurrent.decimalSeparator!)

        let negativeScalar = UnicodeScalar("-")

        var hasDecimalSeparator = false
        var hasMinus = false

        var hasDigits = false

        for c in string.unicodeScalars {
            if whitespaces.contains(c) {
                continue
            }

            if decimalDigits.contains(c) {
                hasDigits = true
                continue
            }

            if decimalSeparator == c {
                if hasDecimalSeparator || !hasDigits {
                    return false
                } else {
                    hasDecimalSeparator = true
                    continue
                }
            }

            if negativeScalar == c {
                if hasDigits || hasMinus {
                    return false
                } else {
                    hasMinus = true
                    continue
                }
            }

            return false
        }
        return true
    }
}
