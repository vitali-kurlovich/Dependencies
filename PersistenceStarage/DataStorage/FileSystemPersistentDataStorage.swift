//
//  FileSystemPersistentDataStorage.swift
//  VetChat
//
//  Created by Vitali Kurlovich on 11/16/18.
//  Copyright © 2018 SIA Mystic Moments. All rights reserved.
//

import Foundation

extension PersistentStorage {
    static func fileStorage(url: URL,
                            compressionAlgorithm: Data.CompressionAlgorithm? = nil,
                            options writingOptions: Data.WritingOptions = .atomic,
                            fileManager: FileManager = FileManager.default,
                            coder: StorageCoder<StoredElement> = JSONStorageCoder<StoredElement>()) -> Self? {
        guard let storage = FileSystemPersistentDataStorage(url: url, options: writingOptions, fileManager: fileManager) else {
            return nil
        }

        return self.init(storage: storage, compressionAlgorithm: compressionAlgorithm, coder: coder)
    }

    static func fileStorage(fileName: String,
                            compressionAlgorithm: Data.CompressionAlgorithm? = nil,
                            options writingOptions: Data.WritingOptions = .atomic,
                            for searchPath: FileManager.SearchPathDirectory = .documentDirectory,
                            in domainMask: FileManager.SearchPathDomainMask = .userDomainMask,
                            fileManager: FileManager = .default,
                            coder: StorageCoder<StoredElement> = JSONStorageCoder<StoredElement>()) -> Self? {
        guard let storage = FileSystemPersistentDataStorage(fileName: fileName, options: writingOptions, for: searchPath, in: domainMask, fileManager: fileManager) else {
            return nil
        }

        return self.init(storage: storage, compressionAlgorithm: compressionAlgorithm, coder: coder)
    }
}

class FileSystemPersistentDataStorage: PersistentDataStorage {
    let url: URL
    let writingOptions: Data.WritingOptions
    private let fileManager: FileManager

    init?(url: URL,
          options writingOptions: Data.WritingOptions = .atomic,
          fileManager: FileManager = FileManager.default) {
        let url = url.standardized

        assert(url.isFileURL, "url must contain path in local file system")
        assert(!url.hasDirectoryPath, "url can't be directory path")

        #if DEBUG
            print("FileSystemPersistentDataStorage: \(url)")
        #endif

        self.url = url
        self.writingOptions = writingOptions
        self.fileManager = fileManager
    }

    convenience init?(fileName: String,
                      options writingOptions: Data.WritingOptions = .atomic,
                      for searchPath: FileManager.SearchPathDirectory = .documentDirectory,
                      in domainMask: FileManager.SearchPathDomainMask = .userDomainMask,
                      fileManager: FileManager = .default) {
        assert(fileName.count > 0, "file name can't be empty")

        guard var url = fileManager.urls(for: searchPath, in: domainMask).first else {
            return nil
        }

        url.appendPathComponent(fileName, isDirectory: false)

        self.init(url: url, options: writingOptions, fileManager: fileManager)
    }

    func read() -> Data? {
        let path = url.absoluteString
        guard fileManager.fileExists(atPath: path) else {
            return nil
        }

        return try? Data(contentsOf: url)
    }

    @discardableResult
    func write(_ data: Data?) -> Bool {
        guard let data = data else {
            return remove(fileURL: url)
        }

        let dirUrl = url.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: dirUrl.path) {
            do {
                try fileManager.createDirectory(at: dirUrl, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return false
            }
        }

        do {
            try data.write(to: url, options: writingOptions)
            return true
        } catch {
            return false
        }
    }

    private
    func remove(fileURL _: URL) -> Bool {
        let path = url.path
        guard fileManager.fileExists(atPath: path) else {
            return true
        }

        do {
            try fileManager.removeItem(at: url)
            return true
        } catch {
            return false
        }
    }
}
