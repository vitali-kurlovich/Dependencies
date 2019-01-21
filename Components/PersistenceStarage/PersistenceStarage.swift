//
//  PersistenceStarage.swift
//  VetChat
//
//  Created by Vitali Kurlovich on 11/15/18.
//  Copyright © 2018 SIA Mystic Moments. All rights reserved.
//

import Foundation

protocol PersistentDataStorage {
    func read() -> Data?
    func write(_ data: Data?) -> Bool
}

class StorageCoder<StoredType: Codable> {
    enum CoderError: Error {
        case coderError
    }

    func decode(from _: Data) throws -> StoredType {
        throw CoderError.coderError
    }

    func encode(_: StoredType) throws -> Data {
        throw CoderError.coderError
    }
}

final class JSONStorageCoder<StoredElement: Codable>: StorageCoder<StoredElement> {
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    override func decode(from data: Data) throws -> StoredElement {
        return try decoder.decode(StoredElement.self, from: data)
    }

    override func encode(_ value: StoredElement) throws -> Data {
        return try encoder.encode(value)
    }

    init(decoder: JSONDecoder = JSONDecoder(), encoder: JSONEncoder = JSONEncoder()) {
        self.decoder = decoder
        self.encoder = encoder
    }
}

final class PersistentStorage<StoredElement: Codable> {
    let storage: PersistentDataStorage
    let compressionAlgorithm: Data.CompressionAlgorithm?

    private let coder: StorageCoder<StoredElement>

    init(storage: PersistentDataStorage,
         compressionAlgorithm: Data.CompressionAlgorithm? = nil,
         coder: StorageCoder<StoredElement> = JSONStorageCoder<StoredElement>()) {
        self.storage = storage
        self.compressionAlgorithm = compressionAlgorithm
        self.coder = coder
    }

    func read() -> StoredElement? {
        guard let readData = storage.read() else {
            return nil
        }

        if let algo = compressionAlgorithm {
            guard let data = readData.decompress(withAlgorithm: algo) else {
                return nil
            }
            return try? coder.decode(from: data)
        }
        return try? coder.decode(from: readData)
    }

    @discardableResult
    func write(_ element: StoredElement?) -> Bool {
        guard let element = element else {
            return storage.write(nil)
        }

        guard let data = try? coder.encode(element) else {
            return false
        }

        if compressionAlgorithm == nil {
            #if DEBUG
                print("PersistentStorage: \(data.count) bytes to write")
            #endif
            return storage.write(data)
        }

        guard let algo = compressionAlgorithm,
            let compressed = data.compress(withAlgorithm: algo) else {
            return false
        }

        #if DEBUG
            print("PersistentStorage: \(compressed.count) bytes to write")
            print("PersistentStorage: uncompressed/compressed \(data.count)/\(compressed.count)")
        #endif

        return storage.write(compressed)
    }
}
