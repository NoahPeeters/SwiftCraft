//
//  String+Serializable.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

extension String: Serializable {
    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        let length = try VarInt32(from: buffer).integer
        let stringBytes = try buffer.read(lenght: length)
        let stringData = Data(stringBytes)

        guard let string = String(data: stringData, encoding: .utf8) else {
            throw TypeDeserializeError.invalidStringData
        }

        self = string
    }

    public func serialize<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        let stringData = data(using: .utf8)!
        let stringBytes = Array(stringData)

        let length = VarInt32(Int32(stringBytes.count))
        length.serialize(to: buffer)

        buffer.write(elements: stringBytes)
    }

    /// Errors which can occure while deserializing a string.
    public enum TypeDeserializeError: Error {
        /// The serialized data is not a valid utf8 string.
        case invalidStringData
    }
}
