//
//  PersistentCache.swift
//  VetChat
//
//  Created by Vitali Kurlovich on 11/15/18.
//  Copyright © 2018 SIA Mystic Moments. All rights reserved.
//

import Foundation

typealias PersistentKey = Codable & Hashable
typealias PersistentElement = Codable & Equatable

final class PersistentKeyValueStorage<Key: PersistentKey, Value: PersistentElement> {
    typealias Storage = PersistentStorage<[Key: Value]>
    private(set)
    var haveChanges = false

    private
    let storage: Storage

    private
    lazy var memoryKeyValue: [Key: Value] = {
        guard let items = storage.read(), items.count > 0 else {
            return [Key: Value]()
        }
        return items
    }()

    init(storage: Storage) {
        self.storage = storage
    }
}

extension PersistentKeyValueStorage {
    var count: Int {
        return memoryKeyValue.count
    }

    var capacity: Int {
        return memoryKeyValue.capacity
    }

    func removeAll() {
        if memoryKeyValue.count > 0 {
            haveChanges = true
            memoryKeyValue.removeAll()
        }
    }
}

extension PersistentKeyValueStorage {
    subscript(forKey: Key) -> Value? {
        get {
            return memoryKeyValue[forKey]
        }

        set(value) {
            guard memoryKeyValue[forKey] != value else {
                return
            }
            haveChanges = true
            memoryKeyValue[forKey] = value
        }
    }
}

extension PersistentKeyValueStorage {
    @discardableResult
    func synchronize() -> Bool {
        guard haveChanges else {
            return true
        }

        let model = memoryKeyValue.count > 0 ? memoryKeyValue : nil

        let success = storage.write(model)
        haveChanges = !success
        return success
    }
}

extension PersistentKeyValueStorage: Sequence {
    typealias Iterator = DictionaryIterator<Key, Value>

    func makeIterator() -> Iterator {
        return memoryKeyValue.makeIterator()
    }
}

extension PersistentKeyValueStorage: Collection {
    typealias Index = DictionaryIndex<Key, Value>

    var startIndex: Index {
        return memoryKeyValue.startIndex
    }

    var endIndex: Index {
        return memoryKeyValue.endIndex
    }

    subscript(position: Index) -> Iterator.Element {
        precondition(indices.contains(position), "out of bounds")
        let dictionaryElement = memoryKeyValue[position]
        return dictionaryElement
    }

    func index(after i: Index) -> Index {
        return memoryKeyValue.index(after: i)
    }
}
