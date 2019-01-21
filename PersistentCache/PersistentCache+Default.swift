//
//  PersistentCache+Default.swift
//  VetChat
//
//  Created by Vitali Kurlovich on 11/23/18.
//  Copyright © 2018 SIA Mystic Moments. All rights reserved.
//

import Foundation

private
let defaultLifeTime = TimeInterval(7 * 24 * 60 * 60)

extension PersistentCache {
    static func userDefaults(key: String,
                             compressionAlgorithm: Data.CompressionAlgorithm? = nil,
                             userDefaults: UserDefaults = UserDefaults.standard,
                             defaultLifetime: TimeInterval = defaultLifeTime) -> PersistentCache<Key, Value>? {
        let algo = compressionAlgorithm

        typealias CacheItem = PersistentCache<Key, Value>.CacheItem

        let persistentStorage = PersistentKeyValueStorage<Key, CacheItem>.userDefaults(key: key, compressionAlgorithm: algo, userDefaults: userDefaults)

        return PersistentCache(persistentStorage: persistentStorage, defaultLifetime: defaultLifetime)
    }
}

extension PersistentCache {
    static func fileStorage(url: URL,
                            compressionAlgorithm: Data.CompressionAlgorithm? = nil,
                            options writingOptions: Data.WritingOptions = .atomic,
                            fileManager: FileManager = FileManager.default,
                            defaultLifetime: TimeInterval = defaultLifeTime) -> PersistentCache<Key, Value>? {
        let algo = compressionAlgorithm

        typealias CacheItem = PersistentCache<Key, Value>.CacheItem

        guard let persistentStorage = PersistentKeyValueStorage<Key, CacheItem>.fileStorage(url: url, compressionAlgorithm: algo, options: writingOptions, fileManager: fileManager) else {
            return nil
        }

        return PersistentCache(persistentStorage: persistentStorage, defaultLifetime: defaultLifetime)
    }

    static func fileStorage(fileName: String,
                            compressionAlgorithm: Data.CompressionAlgorithm? = nil,
                            options writingOptions: Data.WritingOptions = .atomic,
                            for searchPath: FileManager.SearchPathDirectory = .cachesDirectory,
                            in domainMask: FileManager.SearchPathDomainMask = .userDomainMask,
                            fileManager: FileManager = .default,
                            defaultLifetime: TimeInterval = defaultLifeTime) -> PersistentCache<Key, Value>? {
        let algo = compressionAlgorithm

        typealias CacheItem = PersistentCache<Key, Value>.CacheItem

        guard let persistentStorage = PersistentKeyValueStorage<Key, CacheItem>.fileStorage(fileName: fileName, compressionAlgorithm: algo, options: writingOptions, for: searchPath, in: domainMask, fileManager: fileManager) else {
            return nil
        }

        return PersistentCache(persistentStorage: persistentStorage, defaultLifetime: defaultLifetime)
    }
}
