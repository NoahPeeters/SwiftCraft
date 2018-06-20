//
//  Dictionary+Serializable.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

extension Dictionary: DeserializableDataType where Key: DeserializableDataType, Value: DeserializableDataType {
    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        let count = try VarInt32(from: buffer).value

        self.init(uniqueKeysWithValues: try (0..<count).map { _ in
            let key = try Key.init(from: buffer)
            let value = try Value.init(from: buffer)
            return (key, value)
        })
    }
}

extension Dictionary: SerializableDataType where Key: SerializableDataType, Value: SerializableDataType {
    public func serialize<Buffer: ByteWriteBuffer>(to buffer: Buffer) {
        VarInt32(count).serialize(to: buffer)
        forEach {
            $0.key.serialize(to: buffer)
            $0.value.serialize(to: buffer)
        }
    }
}
