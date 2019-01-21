//
//  PersistentCache.swift
//  VetChat
//
//  Created by Vitali Kurlovich on 11/22/18.
//  Copyright © 2018 SIA Mystic Moments. All rights reserved.
//

import Foundation

enum PersistentCachePolicy {
    case onlyIfCache
    case ignoreCache
    case maxAge(age: TimeInterval)
    case immutable
    case onlyCached
}

class PersistentCache<Key: PersistentKey, Value: PersistentElement> {
    let defaultLifetime: TimeInterval

    struct CacheItem: PersistentElement {
        let created: Date
        let maxage: TimeInterval
        let value: Value
    }

    private
    let persistentStorage: PersistentKeyValueStorage<Key, CacheItem>

    private
    lazy var applicationObserver: ApplicationObserver = {
        ApplicationObserver()
    }()

    private
    lazy var memoryCache: TimeOutMemoryCache<Key, Value> = {
        let cache = TimeOutMemoryCache<Key, Value>(minimumCapacity: persistentStorage.capacity, defaultLifetime: defaultLifetime)

        var outdated = [Key]()
        outdated.reserveCapacity(persistentStorage.count)
        let currentDate = Date()
        for (key, value) in persistentStorage {
            if isOutdated(item: value, currentDate: currentDate) {
                outdated.append(key)
            } else {
                cache[key] = (created: value.created, maxage: value.maxage, value: value.value)
            }
        }

        for key in outdated {
            persistentStorage[key] = nil
        }

        self.applicationObserver.didEnterBackground = { [weak self] in
            self?.synchronize()
        }

        return cache
    }()

    init(persistentStorage: PersistentKeyValueStorage<Key, CacheItem>, defaultLifetime: TimeInterval = TimeInterval(7 * 24 * 60 * 60)) {
        self.defaultLifetime = defaultLifetime
        self.persistentStorage = persistentStorage
    }
}

extension PersistentCache {
    subscript(forKey: Key) -> Value? {
        get {
            return self[forKey, policy: .onlyIfCache]
        }

        set(value) {
            self[forKey, policy: .onlyIfCache] = value
        }
    }

    subscript(forKey: Key, policy cachePolicy: PersistentCachePolicy) -> Value? {
        get {
            switch cachePolicy {
            case .onlyIfCache, .immutable:
                guard let cachedValue: TimeOutMemoryCache<Key, Value>.CacheItem = memoryCache[forKey] else {
                    return nil
                }
                return cachedValue.value

            case .ignoreCache:
                return nil

            case let .maxAge(age):
                guard let cachedValue: TimeOutMemoryCache<Key, Value>.CacheItem = memoryCache[forKey] else {
                    return nil
                }

                let now = Date()
                let itemAge = now.timeIntervalSince(cachedValue.created)

                if itemAge <= age {
                    let value = cachedValue.value
                    return value
                }

                return nil
            case .onlyCached:
                return memoryCache[forKey]?.value
            }
        }

        set(value) {
            guard let value = value else {
                memoryCache[forKey] = nil
                return
            }

            switch cachePolicy {
            case .onlyIfCache:
                memoryCache[forKey] = (created: Date(), maxage: defaultLifetime, value: value)
                break

            case .ignoreCache:
                memoryCache[forKey] = nil
                break

            case let .maxAge(age):
                memoryCache[forKey] = (created: Date(), maxage: age, value: value)
                break

            case .immutable:
                memoryCache[forKey] = (created: Date(), maxage: 0, value: value)
                break
            case .onlyCached:
                break
            }
        }
    }
}

extension PersistentCache {
    func update(key: Key, value: Value) {
        if let cached = memoryCache[key] {
            memoryCache[key] = (created: Date(), maxage: cached.maxage, value: value)
        } else {
            self[key] = value
        }
    }
}

extension PersistentCache {
    @discardableResult
    func synchronize() -> Bool {
        var outdated = [Key]()
        outdated.reserveCapacity(persistentStorage.count)
        let currentDate = Date()
        for (key, value) in persistentStorage {
            if isOutdated(item: value, currentDate: currentDate) {
                outdated.append(key)
            }
        }

        for key in outdated {
            persistentStorage[key] = nil
        }

        for item in memoryCache {
            let cacheItem = CacheItem(created: item.value.created, maxage: item.value.maxage, value: item.value.value)
            persistentStorage[item.key] = cacheItem
        }

        return persistentStorage.synchronize()
    }
}

extension PersistentCache {
    var count: Int {
        return memoryCache.count
    }

    var capacity: Int {
        return memoryCache.capacity
    }

    func removeAll() {
        memoryCache.removeAll()
    }
}

extension PersistentCache: Sequence {
    typealias Iterator = TimeOutMemoryCache<Key, Value>.Iterator

    func makeIterator() -> Iterator {
        return memoryCache.makeIterator()
    }
}

extension PersistentCache: Collection {
    typealias Index = TimeOutMemoryCache<Key, Value>.Index

    var startIndex: Index {
        return memoryCache.startIndex
    }

    var endIndex: Index {
        return memoryCache.endIndex
    }

    subscript(position: Index) -> Iterator.Element {
        precondition(indices.contains(position), "out of bounds")
        let dictionaryElement = memoryCache[position]
        return dictionaryElement
    }

    func index(after i: Index) -> Index {
        return memoryCache.index(after: i)
    }
}

private
extension PersistentCache {
    func isOutdated(item: CacheItem, currentDate: Date) -> Bool {
        return item.maxage != 0 && currentDate.timeIntervalSince(item.created) > item.maxage
    }
}
