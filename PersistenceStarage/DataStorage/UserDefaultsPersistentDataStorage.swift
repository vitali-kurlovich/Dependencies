//
//  UserDefaultsPersistentDataStorage.swift
//  VetChat
//
//  Created by Vitali Kurlovich on 11/15/18.
//  Copyright © 2018 SIA Mystic Moments. All rights reserved.
//

import Foundation

extension PersistentStorage {
    static func userDefaults(key: String,
                             compressionAlgorithm: Data.CompressionAlgorithm? = nil,
                             userDefaults: UserDefaults = UserDefaults.standard,
                             coder: StorageCoder<StoredElement> = JSONStorageCoder<StoredElement>()) -> Self {
        let storage = UserDefaultsPersistentDataStorage(key: key, userDefaults: userDefaults)

        return self.init(storage: storage, compressionAlgorithm: compressionAlgorithm, coder: coder)
    }
}

final class UserDefaultsPersistentDataStorage: PersistentDataStorage {
    let userDefaults: UserDefaults
    let key: String

    init(key: String, userDefaults: UserDefaults = UserDefaults.standard) {
        assert(key.count > 0, "key can't be empty string")

        self.userDefaults = userDefaults
        self.key = key
    }

    // MARK: - PersistentDataStorage

    func read() -> Data? {
        let data = userDefaults.object(forKey: key) as? Data
        return data
    }

    @discardableResult
    func write(_ data: Data?) -> Bool {
        guard let data = data else {
            userDefaults.removeObject(forKey: key)
            return userDefaults.synchronize()
        }

        userDefaults.set(data, forKey: key)
        return userDefaults.synchronize()
    }
}
