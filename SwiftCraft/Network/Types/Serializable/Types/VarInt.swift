//
//  VarInt.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

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
    /// Creates a new VarInt32 from an integer.
    ///
    /// - Parameter value: The value of the VarInt32.
    public init(_ value: Int) {
        self.init(Int32(value))
    }

    /// Converts the value to an `Int`.
    public var integer: Int {
        return Int(value)
    }
}

extension VarInt where IntegerType == Int64 {
    /// Creates a new VarInt64 from an integer.
    ///
    /// - Parameter value: The value of the VarInt64.
    public init(_ value: Int) {
        self.init(Int64(value))
    }

    /// Converts the value to an `Int`.
    public var integer: Int {
        return Int(value)
    }
}
