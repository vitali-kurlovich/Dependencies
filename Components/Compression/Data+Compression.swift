//
//  Compression.swift
//  VetChat
//
//  Created by Vitali Kurlovich on 11/15/18.
//  Copyright © 2018 SIA Mystic Moments. All rights reserved.
//

import Compression
import Foundation

extension Data {
    public
    enum CompressionAlgorithm {
        case zlib
        case lzfse
        case lzma
        case lz4
    }

    public
    func compress(withAlgorithm algo: CompressionAlgorithm = .lzma) -> Data? {
        return withUnsafeBytes { (sourcePtr: UnsafePointer<UInt8>) -> Data? in
            let config = (operation: COMPRESSION_STREAM_ENCODE, algorithm: algo.lowLevelType)
            return perform(config, source: sourcePtr, sourceSize: count)
        }
    }

    public
    func decompress(withAlgorithm algo: CompressionAlgorithm = .lzma) -> Data? {
        return withUnsafeBytes { (sourcePtr: UnsafePointer<UInt8>) -> Data? in
            let config = (operation: COMPRESSION_STREAM_DECODE, algorithm: algo.lowLevelType)
            return perform(config, source: sourcePtr, sourceSize: count)
        }
    }
}

fileprivate
extension Data.CompressionAlgorithm {
    var lowLevelType: compression_algorithm {
        switch self {
        case .zlib: return COMPRESSION_ZLIB
        case .lzfse: return COMPRESSION_LZFSE
        case .lz4: return COMPRESSION_LZ4
        case .lzma: return COMPRESSION_LZMA
        }
    }
}

fileprivate
typealias Config = (operation: compression_stream_operation, algorithm: compression_algorithm)

fileprivate
func perform(_ config: Config, source: UnsafePointer<UInt8>, sourceSize: Int, preload: Data = Data()) -> Data? {
    guard config.operation == COMPRESSION_STREAM_ENCODE || sourceSize > 0 else { return nil }

    let streamBase = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1)
    defer { streamBase.deallocate() }
    var stream = streamBase.pointee

    let status = compression_stream_init(&stream, config.operation, config.algorithm)
    guard status != COMPRESSION_STATUS_ERROR else { return nil }
    defer { compression_stream_destroy(&stream) }

    let bufferSize = Swift.max(Swift.min(sourceSize, 64 * 1024), 64)
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    defer { buffer.deallocate() }

    stream.dst_ptr = buffer
    stream.dst_size = bufferSize
    stream.src_ptr = source
    stream.src_size = sourceSize

    var res = preload
    let flags: Int32 = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)

    while true {
        switch compression_stream_process(&stream, flags) {
        case COMPRESSION_STATUS_OK:
            guard stream.dst_size == 0 else { return nil }
            res.append(buffer, count: stream.dst_ptr - buffer)
            stream.dst_ptr = buffer
            stream.dst_size = bufferSize

        case COMPRESSION_STATUS_END:
            res.append(buffer, count: stream.dst_ptr - buffer)
            return res

        default:
            return nil
        }
    }
}
