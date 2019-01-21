//
//  PhoneNumberValidator.swift
//  VetChat
//
//  Created by Vitali Kurlovich on 7/12/18.
//  Copyright © 2018 SIA Mystic Moments. All rights reserved.
//

import Foundation

struct PhoneNumberValidator: Validator {
    func validate(_ obj: Any?) -> Bool {
        guard let string = obj as? String, string.count > 0 else {
            return false
        }

        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == string.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}
