//
//  Optional+Serializable.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

extension Optional: DeserializableDataType where Wrapped: DeserializableDataType {
    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        let hasValue = try Bool(from: buffer)

        if hasValue {
            self = try Wrapped(from: buffer)
        } else {
            self = nil
        }
    }
}

extension Optional: SerializableDataType where Wrapped: SerializableDataType {
    public func serialize<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        if let wrapped = self {
            true.serialize(to: buffer)
            wrapped.serialize(to: buffer)
        } else {
            false.serialize(to: buffer)
        }
    }
}
