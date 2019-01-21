//
//  TimeOutMemoryCache.swift
//  VetChat
//
//  Created by Vitali Kurlovich on 11/19/18.
//  Copyright © 2018 SIA Mystic Moments. All rights reserved.
//

import Foundation

final class TimeOutMemoryCache<Key: Hashable, Value: Equatable> {
    let defaultLifetime: TimeInterval

    typealias CacheItem = (created: Date, maxage: TimeInterval, value: Value)

    private
    var cache: Dictionary<Key, CacheItem>

    init(defaultLifetime: TimeInterval = TimeInterval(5 * 60)) {
        self.defaultLifetime = defaultLifetime
        cache = Dictionary<Key, CacheItem>()
    }

    init(minimumCapacity: Int, defaultLifetime: TimeInterval = TimeInterval(5 * 60)) {
        self.defaultLifetime = defaultLifetime
        cache = Dictionary<Key, CacheItem>(minimumCapacity: minimumCapacity)
    }
}

extension TimeOutMemoryCache {
    var count: Int {
        return cache.count
    }

    var capacity: Int {
        return cache.capacity
    }

    func removeAll() {
        cache.removeAll()
    }
}

extension TimeOutMemoryCache: Sequence {
    typealias Iterator = DictionaryIterator<Key, CacheItem>

    func makeIterator() -> Iterator {
        processCache()
        return cache.makeIterator()
    }
}

extension TimeOutMemoryCache: Collection {
    typealias Index = DictionaryIndex<Key, CacheItem>

    var startIndex: Index {
        return cache.startIndex
    }

    var endIndex: Index {
        return cache.endIndex
    }

    subscript(position: Index) -> Iterator.Element {
        precondition(indices.contains(position), "out of bounds")
        let dictionaryElement = cache[position]
        return dictionaryElement
    }

    func index(after i: Index) -> Index {
        return cache.index(after: i)
    }
}

extension TimeOutMemoryCache {
    subscript(forKey: Key) -> CacheItem? {
        get {
            guard let item = cache[forKey] else {
                return nil
            }

            if isOutdated(item: item, currentDate: Date()) {
                self[forKey] = nil
                return nil
            }

            return item
        }

        set(element) {
            guard let _ = element?.value else {
                cache.removeValue(forKey: forKey)
                return
            }

            if cache.capacity >= cache.count {
                processCache()
            }

            cache[forKey] = element
        }
    }
}

private
extension TimeOutMemoryCache {
    func processCache() {
        var keys = [Key]()
        keys.reserveCapacity(cache.count)
        let date = Date()
        for (key, item) in cache {
            guard isOutdated(item: item, currentDate: date) else {
                continue
            }
            keys.append(key)
        }

        for key in keys {
            self[key] = nil
        }
    }

    func isOutdated(item: CacheItem, currentDate: Date) -> Bool {
        return item.maxage != 0 && currentDate.timeIntervalSince(item.created) > item.maxage
    }
}
