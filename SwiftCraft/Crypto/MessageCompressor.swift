//
//  MessageCompressor.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 22.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

public class MessageCompressor {
    let threshold: Int

    init(threshold: Int) {
        self.threshold = threshold
    }

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

    func decompressMessage(_ message: ByteArray) throws -> ByteArray {
        let buffer = Buffer(elements: message)
        let dataLength = try VarInt32(from: buffer)
        let data = try buffer.readRemainingElements()

        if dataLength.value == 0 {
            return data
        } else if let decompressedMessage = Data(bytes: data).deflate() {
            return Array(decompressedMessage)
        } else {
            throw MessageCompressorError.cannotDecompresData
        }
    }
}

enum MessageCompressorError: Error {
    case cannotDecompresData
    case cannotCompressData
}

extension Buffer {
    func readRemainingElements() throws -> [Element] {
        return try read(lenght: remainingData())
    }
}
