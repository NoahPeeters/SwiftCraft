//
//  String+Serializable.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

extension String: Serializable {
    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        let stringData = try Data(from: buffer)

        guard let string = String(data: stringData, encoding: .utf8) else {
            throw TypeDeserializeError.invalidStringData
        }

        self = string
    }

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, count: Int) throws {
        let stringData = try Data(from: buffer, count: count)

        guard let string = String(data: stringData, encoding: .utf8) else {
            throw TypeDeserializeError.invalidStringData
        }

        self = string
    }

    public func serialize<Buffer: ByteWriteBuffer>(to buffer: Buffer) {
        let stringData = data(using: .utf8)!
        stringData.serialize(to: buffer)
    }

    /// Errors which can occure while deserializing a string.
    public enum TypeDeserializeError: Error {
        /// The serialized data is not a valid utf8 string.
        case invalidStringData
    }
}
