//
//  Array+Serializable.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

extension Array: DeserializableDataType where Element: DeserializableDataType {
    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        let count = try VarInt32(from: buffer).value
        self = try (0..<count).map { _ in
            try Element(from: buffer)
        }
    }

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, count: Int) throws {
        self = try (0..<count).map { _ in
            try Element(from: buffer)
        }
    }
}

extension Array: SerializableDataType where Element: SerializableDataType {
    public func serialize<Buffer: ByteWriteBuffer>(to buffer: Buffer) {
        VarInt32(count).serialize(to: buffer)
        forEach {
            $0.serialize(to: buffer)
        }
    }
}
