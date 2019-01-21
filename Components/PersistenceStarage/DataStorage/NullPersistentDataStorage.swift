//
//  NullPersistentDataStorage.swift
//  VetChat
//
//  Created by Vitali Kurlovich on 11/25/18.
//  Copyright © 2018 SIA Mystic Moments. All rights reserved.
//

import Foundation

extension PersistentStorage {
    static func nullStorage() -> Self {
        let storage = NullPersistentDataStorage()
        return self.init(storage: storage, compressionAlgorithm: nil, coder: NullStorageCoder())
    }

    private
    final class NullStorageCoder: StorageCoder<StoredElement> {
        override func encode(_: StoredElement) throws -> Data {
            return Data()
        }
    }
}

final class NullPersistentDataStorage: PersistentDataStorage {
    func read() -> Data? {
        return nil
    }

    func write(_: Data?) -> Bool {
        return true
    }
}
