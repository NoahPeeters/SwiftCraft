//
//  Array+Serializable.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

extension Array: DeserializableDataType where Element: DeserializableDataType {
    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        let count = try VarInt32(from: buffer).value

        self = try (0..<count).map { _ in
            return try Element(from: buffer)
        }
    }

    public init<Buffer: ReadBuffer>(from buffer: Buffer, count: Int) throws where Buffer.Element == Byte {
        self = try (0..<count).map { _ in
            return try Element(from: buffer)
        }
    }
}

extension Array: SerializableDataType where Element: SerializableDataType {
    public func serialize<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        VarInt32(count).serialize(to: buffer)
        forEach {
            $0.serialize(to: buffer)
        }
    }
}
