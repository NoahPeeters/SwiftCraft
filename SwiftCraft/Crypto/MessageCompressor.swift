//
//  MessageCompressor.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 22.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Handels the compression and decompression of an incomming and an outgoing data.
public class MessageCompressor {
    /// The threshold for the size of a packet to compress.
    let threshold: Int

    /// Creates a new `MessageCompressor`.
    ///
    /// - Parameter threshold: The threshold for the size of a packet to compress.
    init(threshold: Int) {
        self.threshold = threshold
    }

    /// Compresses a message.
    ///
    /// - Parameter message: The message to compress.
    /// - Returns: The compressed message.
    /// - Throws: Compression errors.
    func compressMessage(_ message: ByteArray) throws -> ByteArray {
        guard message.count >= threshold else {
            return [0] + message
        }

        let messageData = Data(bytes: message)
        guard let compressedMessage = messageData.zip() else {
            throw MessageCompressorError.cannotCompressData
        }

        let dataLength = VarInt32(messageData.count).directEncode()

        return dataLength + Array(compressedMessage)
    }

    /// Decomresses a message.
    ///
    /// - Parameter message: The message to decompress.
    /// - Returns: The decompressed message.
    /// - Throws: Decompression errors.
    func decompressMessage(_ message: ByteArray) throws -> ByteArray {
        let buffer = Buffer(elements: message)
        let dataLength = try VarInt32(from: buffer)
        let data = buffer.readRemainingElements()

        if dataLength.value == 0 {
            return data
        } else if let decompressedMessage = Data(bytes: data).deflate() {
            return Array(decompressedMessage)
        } else {
            throw MessageCompressorError.cannotDecompresData
        }
    }

    /// Errors of the `MessageCompressor`.
    ///
    /// - cannotDecompresData: A general decompression error.
    /// - cannotCompressData: A general compression error.
    enum MessageCompressorError: Error {
        case cannotDecompresData
        case cannotCompressData
    }
}

extension Buffer {
    /// Reads all remaining data of the buffer.
    ///
    /// - Returns: The read data.
    /// - Throws:
    fileprivate func readRemainingElements() -> [Element] {
        return (try? read(lenght: remainingData())) ?? []
    }
}
