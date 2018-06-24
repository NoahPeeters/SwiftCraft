//
//  MessageCompressor.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 22.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Handels the compression and decompression of an incomming and an outgoing data.
internal class MessageCompressor {
    /// The threshold for the size of a packet to compress.
    private let threshold: Int

    /// Creates a new `MessageCompressor`.
    ///
    /// - Parameter threshold: The threshold for the size of a packet to compress.
    internal init(threshold: Int) {
        self.threshold = threshold
    }

    /// Compresses a message.
    ///
    /// - Parameter message: The message to compress.
    /// - Returns: The compressed message.
    /// - Throws: Compression errors.
    internal func compressMessage(_ message: ByteArray) throws -> ByteArray {
        guard message.count >= threshold else {
            return [0] + message
        }

        let messageData = Data(bytes: message)
        guard let compressedMessage = messageData.zip() else {
            throw MessageCompressorError.cannotCompressData
        }

        let dataLength = VarInt32(messageData.count).directSerialized()

        return dataLength + Array(compressedMessage)
    }

    /// Decomresses a message.
    ///
    /// - Parameter message: The message to decompress.
    /// - Returns: The decompressed message.
    /// - Throws: Decompression errors.
    internal func decompressMessage(_ message: ByteArray) throws -> ByteArray {
        let buffer = Buffer(elements: message)
        let dataLength = try VarInt32(from: buffer)
        let data = buffer.readRemainingElements()

        if dataLength.value == 0 {
            return data
        } else if let decompressedMessage = Data(bytes: data).unzip() {
            return Array(decompressedMessage)
        } else {
            throw MessageCompressorError.cannotDecompresData
        }
    }
}

/// Errors of the `MessageCompressor`.
public enum MessageCompressorError: Error {
    /// A general decompression error.
    case cannotDecompresData

    /// A general compression error.
    case cannotCompressData
}
