//
//  SerializableDataType.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Can be serialized to a buffer.
public protocol SerializableDataType {
    /// Serializes its content to the given buffer.
    ///
    /// - Parameter buffer: The buffer to serialize the data to.
    func serialize<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte
}

extension SerializableDataType {
    /// Serializes the type and returns the data.
    ///
    /// - Returns: The serialized type.
    public func directSerialized() -> ByteArray {
        let buffer = ByteBuffer()
        serialize(to: buffer)
        return buffer.elements
    }
}

/// Can be deserialized from a buffer.
public protocol DeserializableDataType {
    /// Creates a new object by deserializing the content of the given buffer.
    ///
    /// - Parameter buffer: The buffer to deserialize the data from.
    /// - Throws: Any deserializing error.
    init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte
}

extension DeserializableDataType {
    /// Deserializes the type from the given data.
    ///
    /// - Parameter bytes: The bytes to derserialize.
    /// - Throws: Any deserializing error.
    public init(from bytes: ByteArray) throws {
        let buffer = ByteBuffer(elements: bytes)
        try self.init(from: buffer)
    }
}

/// Can be serialized to and deserialized from a Buffer
public typealias Serializable = SerializableDataType & DeserializableDataType
