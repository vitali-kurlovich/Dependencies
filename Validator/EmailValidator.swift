//
//  EmailValidator.swift
//  Put Capital
//
//  Created by Vitali Kurlovich on 5/5/18.
//  Copyright © 2018 Vitali Kurlovich. All rights reserved.
//

import Foundation

struct EmailValidator: Validator {
    fileprivate
    let regex = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
        "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
        "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
        "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
        "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
        "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"

    // MARK: Validator

    func validate(_ obj: Any?) -> Bool {
        guard let string = obj as? String,
            string.count > 5,
            string.count < 255,
            string.contains("@") else {
            return false
        }

        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", regex)
        return emailPredicate.evaluate(with: string)
    }
}
