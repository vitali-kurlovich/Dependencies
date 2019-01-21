//
//  PersistentCacheProvider.swift
//  VetChat
//
//  Created by Vitali Kurlovich on 11/24/18.
//  Copyright © 2018 SIA Mystic Moments. All rights reserved.
//

import Foundation

class PersistentCacheProvider<Key: PersistentKey, Value: PersistentElement> {
    typealias CachePolicy = PersistentCachePolicy
    typealias CompletionHandler = (Value?, Error?) -> Void

    let persistentCache: PersistentCache<Key, Value>

    init(persistentCache: PersistentCache<Key, Value>) {
        self.persistentCache = persistentCache
    }

    func request(key _: Key, completion _: @escaping CompletionHandler) {}

    func fetch(key: Key, policy сachePolicy: CachePolicy = .onlyIfCache, completion: CompletionHandler? = nil) {
        switch сachePolicy {
        case .onlyIfCache, .maxAge, .immutable:
            if let value = persistentCache[key, policy: сachePolicy] {
                completion?(value, nil)
                return
            }

            request(key: key) { [weak self] value, error in
                self?.persistentCache[key, policy: сachePolicy] = value
                completion?(value, error)
            }

            break

        case .ignoreCache:
            request(key: key) { [weak self] value, error in
                if let value = value {
                    self?.persistentCache.update(key: key, value: value)
                } else if error == nil {
                    self?.persistentCache[key] = nil
                }
                completion?(value, error)
            }
            break
        case .onlyCached:
            let value = persistentCache[key, policy: сachePolicy]
            completion?(value, nil)
            break
        }
    }
}

extension PersistentCacheProvider {
    func reset() {
        persistentCache.removeAll()
        persistentCache.synchronize()
    }
}
