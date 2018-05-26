//
//  CodableDataType.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Can be encoded to a buffer.
public protocol EncodableDataType {
    /// Encodes its content to the given buffer.
    ///
    /// - Parameter buffer: The buffer to encode the data to.
    func encode<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte
}

extension EncodableDataType {
    /// Encodes the type and returns the data.
    ///
    /// - Returns: The encoded type.
    public func directEncode() -> ByteArray {
        let buffer = ByteBuffer()
        encode(to: buffer)
        return buffer.elements
    }
}

/// Can be decoded from a buffer.
public protocol DecodableDataType {
    /// Creates a new object by decoding the content of the given buffer.
    ///
    /// - Parameter buffer: The buffer to decode the data from.
    /// - Throws: Any decoding error.
    init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte
}

extension DecodableDataType {
    /// Decodes the type from the given data.
    ///
    /// - Parameter bytes: The bytes to decode.
    /// - Throws: Any decoding error.
    public init(from bytes: ByteArray) throws {
        let buffer = ByteBuffer(elements: bytes)
        try self.init(from: buffer)
    }
}

/// Can be encoded to and decoded from a Buffer
public typealias CodableDataType = EncodableDataType & DecodableDataType
