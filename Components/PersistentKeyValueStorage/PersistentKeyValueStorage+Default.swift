//
//  PersistentKeyValueStorage+Default.swift
//  VetChat
//
//  Created by Vitali Kurlovich on 11/16/18.
//  Copyright © 2018 SIA Mystic Moments. All rights reserved.
//

import Foundation

extension PersistentKeyValueStorage {
    static func userDefaults(key: String,
                             compressionAlgorithm: Data.CompressionAlgorithm? = nil,
                             userDefaults: UserDefaults = UserDefaults.standard) -> Self {
        let algo = compressionAlgorithm

        let storage = Storage.userDefaults(key: key,
                                           compressionAlgorithm: algo,
                                           userDefaults: userDefaults)

        return self.init(storage: storage)
    }
}

extension PersistentKeyValueStorage {
    static func fileStorage(url: URL,
                            compressionAlgorithm: Data.CompressionAlgorithm? = nil,
                            options writingOptions: Data.WritingOptions = .atomic,
                            fileManager: FileManager = FileManager.default) -> Self? {
        let algo = compressionAlgorithm

        guard let storage = Storage.fileStorage(url: url, compressionAlgorithm: algo, options: writingOptions, fileManager: fileManager) else {
            return nil
        }

        return self.init(storage: storage)
    }

    static func fileStorage(fileName: String,
                            compressionAlgorithm: Data.CompressionAlgorithm? = nil,
                            options writingOptions: Data.WritingOptions = .atomic,
                            for searchPath: FileManager.SearchPathDirectory = .documentDirectory,
                            in domainMask: FileManager.SearchPathDomainMask = .userDomainMask,
                            fileManager: FileManager = .default) -> Self? {
        let algo = compressionAlgorithm

        guard let storage = Storage.fileStorage(fileName: fileName,
                                                compressionAlgorithm: algo,
                                                options: writingOptions,
                                                for: searchPath,
                                                in: domainMask,
                                                fileManager: fileManager) else {
            return nil
        }

        return self.init(storage: storage)
    }
}
