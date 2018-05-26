//
//  DirectSerializableDataType.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Serializes and deserializes with raw byte representation.
protocol DirectSerializableDataType: Serializable {}

extension DirectSerializableDataType {
    public func serialize<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        let bytes = toByteArrayBigEndian(value: self)
        buffer.write(elements: bytes)
    }

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        let value = try buffer.read(lenght: MemoryLayout<Self>.size)
        self = fromByteArrayBigEndian(value: value)
    }
}

// MARK: - Helpers

/// Converts any data to a byte array.
///
/// - Parameter value: The data to convert.
/// - Returns: The byte array.
private func toByteArray<T>(value: T) -> ByteArray {
    var value = value
    return withUnsafeBytes(of: &value) { Array($0) }
}

/// Converts any data to a byte array with big endian.
///
/// - Parameter value: The data to convert.
/// - Returns: The big endian byte array.
private func toByteArrayBigEndian<T>(value: T) -> ByteArray {
    return toByteArray(value: value).reversed()
}

/// Converts a byte array to any data type.
///
/// - Parameter value: The byte array to convert.
/// - Returns: The extracted data.
private func fromByteArray<T>(value: ByteArray) -> T {
    return value.withUnsafeBytes {
        $0.baseAddress!.load(as: T.self)
    }
}

/// Converts a big endian byte array to any data type.
///
/// - Parameter value: The big endian byte array to convert.
/// - Returns: The extracted data.
private func fromByteArrayBigEndian<T>(value: ByteArray) -> T {
    return fromByteArray(value: value.reversed())
}
