//
//  SerializableTypes.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

// MARK: - Boolean
extension Bool: Serializable {
    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        self = try buffer.readOne() != 0x00
    }

    public func serialize<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        buffer.write(element: self ? 0x01 : 0x00)
    }
}

// MARK: - Integer
extension Int8: DirectSerializableDataType {}
extension UInt8: DirectSerializableDataType {}
extension Int16: DirectSerializableDataType {}
extension UInt16: DirectSerializableDataType {}
extension Int32: DirectSerializableDataType {}
extension UInt32: DirectSerializableDataType {}
extension Int64: DirectSerializableDataType {}
extension UInt64: DirectSerializableDataType {}

// MARK: - Floating Point
extension Float: DirectSerializableDataType {}
extension Double: DirectSerializableDataType {}

// MARK: - Var Length

/// An integer which can be serialized with a variable length.
public struct VarInt<IntegerType: VarIntIntegerType>: Serializable {
    /// The underlying value
    let value: IntegerType

    /// Creates a new VarInt of a specific type
    ///
    /// - Parameter value: The value to store
    public init(_ value: IntegerType) {
        self.value = value
    }

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        var numRead: IntegerType = 0
        var result: IntegerType = 0
        var lastRead: IntegerType
        repeat {
            guard numRead < IntegerType.maxVarIntByteCount else {
                throw TypeDeserializeError.varIntToBig
            }
            lastRead = try IntegerType(buffer.readOne())
            let value: IntegerType = (lastRead & 0b01111111)
            result |= (value << (7 * numRead))

            numRead += 1
        } while ((lastRead & 0b10000000) != 0)

        self.init(result)
    }

    public func serialize<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        var remainingData = self.value
        repeat {
            var currentByte: Byte = (Byte(remainingData & 0b01111111))
            remainingData = remainingData >>> 7
            if remainingData != 0 {
                currentByte |= 0b10000000
            }
            buffer.write(element: currentByte)
        } while (remainingData != 0)
    }

    /// Errors which can occure while deserializing the int.
    public enum TypeDeserializeError: Error {
        /// The integer serialized is to big for the type.
        case varIntToBig
    }
}

/// A type which can be used as the base integer type for varints
public protocol VarIntIntegerType: FixedWidthInteger & BitPatternShiftable {
    /// The maxium number of bytes allowed in minecraft's VarInt types.
    static var maxVarIntByteCount: Int { get }
}

extension Int32: VarIntIntegerType {
    public static var maxVarIntByteCount: Int {
        return 5
    }
}

extension Int64: VarIntIntegerType {
    public static var maxVarIntByteCount: Int {
        return 10
    }
}

/// Minecraft's VarInt type
public typealias VarInt32 = VarInt<Int32>

/// Minecraft's VarLong type
public typealias VarInt64 = VarInt<Int64>

extension VarInt where IntegerType == Int32 {
    public init(_ value: Int) {
        self.init(Int32(value))
    }
}

extension VarInt where IntegerType == Int64 {
    public init(_ value: Int) {
        self.init(Int64(value))
    }
}

// MARK: - String

extension String: Serializable {
    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        let length = try Int(VarInt32(from: buffer).value)
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

// MARK: - Position

extension Int64 {
    /// Inits a Int64 from a subset of bytes of a UInt64
    ///
    /// - Parameters:
    ///   - bytes: The bytes to use.
    ///   - length: The number of bytes to use for the new integer.
    ///   - rightOffset: The distance from the right end (LSB).
    /// - Experiment:
    ///   Given the following byte array: 1001011010101101100101101010110110010110101011011001011010101101
    ///   When useing length = 8 and right offet = 6 the following bytes will bu used:
    ///   10010110101011011001011010101101100101101010110110_01011010_101101
    ///   Which will result in 90.
    init(from bytes: UInt64, length: Int, rightOffset: Int) {
        let maxNumbers = NSDecimalNumber(decimal: pow(2, length))

        self = Int64((bytes >> rightOffset) & (maxNumbers.uint64Value - 1))
        if self > maxNumbers.int64Value / 2 {
            self -= maxNumbers.int64Value
        }
    }
}

/// A minecraft position struct.
public struct Position: Serializable, Equatable, Hashable {
    /// The x position.
    let x: Int

    /// The y position.
    let y: Int

    /// The z position.
    let z: Int

    /// Creates a new position from the give coordinates.
    ///
    /// - Parameters:
    ///   - x: The x position.
    ///   - y: The y position.
    ///   - z: The z position.
    public init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        let data = try UInt64(from: buffer)

        self.init(
            x: Int(Int64(from: data, length: 26, rightOffset: 38)),
            y: Int(Int64(from: data, length: 12, rightOffset: 26)),
            z: Int(Int64(from: data, length: 26, rightOffset: 0)))
    }

    public func serialize<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        let uintX = UInt64(bitPattern: Int64(x))
        let uintY = UInt64(bitPattern: Int64(y))
        let uintZ = UInt64(bitPattern: Int64(z))

        let result = ((uintX & 0x3FFFFFF) << 38) | ((uintY & 0xFFF) << 26) | (uintZ & 0x3FFFFFF)
        result.serialize(to: buffer)
    }
}

extension Array: DeserializableDataType where Element: DeserializableDataType {
    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        let count = try VarInt32(from: buffer).value

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

extension UUID: Serializable {
    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        var data = try buffer.read(lenght: 16)

        self = withUnsafePointer(to: &data[0]) {
            NSUUID.init(uuidBytes: $0) as UUID
        }
    }

    public func serialize<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        var uuid = self.uuid
        let data = withUnsafePointer(to: &uuid) {
            return Data(bytes: $0, count: 16)
        }

        buffer.write(elements: Array(data))
    }
}

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