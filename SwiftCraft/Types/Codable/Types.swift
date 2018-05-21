//
//  Types.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

enum TypeDecodeError: Error {
    case varIntToBig
    case invalidStringData
}

// MARK: - Boolean
extension Bool: CodableDataType {
    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        self = try buffer.readOne() != 0x00
    }

    public func encode<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        buffer.write(element: self ? 0x01 : 0x00)
    }
}

// MARK: - Integer
extension Int8: DirectCodableDataType {}
extension UInt8: DirectCodableDataType {}
extension Int16: DirectCodableDataType {}
extension UInt16: DirectCodableDataType {}
extension Int32: DirectCodableDataType {}
extension UInt32: DirectCodableDataType {}
extension Int64: DirectCodableDataType {}
extension UInt64: DirectCodableDataType {}

// MARK: - Floating Point
extension Float: DirectCodableDataType {}
extension Double: DirectCodableDataType {}

// MARK: - Var Length

public struct VarInt<IntegerType: VarIntIntegerType>: CodableDataType {
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
                throw TypeDecodeError.varIntToBig
            }
            lastRead = try IntegerType(buffer.readOne())
            let value: IntegerType = (lastRead & 0b01111111)
            result |= (value << (7 * numRead))

            numRead += 1
        } while ((lastRead & 0b10000000) != 0)

        self.init(result)
    }

    public func encode<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
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
}

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

// MARK: - String

extension String: CodableDataType {
    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        let length = try Int(VarInt32(from: buffer).value)
        let stringBytes = try buffer.read(lenght: length)
        let stringData = Data(stringBytes)

        guard let string = String(data: stringData, encoding: .utf8) else {
            throw TypeDecodeError.invalidStringData
        }

        self = string
    }

    public func encode<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        let stringData = data(using: .utf8)!
        let stringBytes = Array(stringData)

        let length = VarInt32(Int32(stringBytes.count))
        length.encode(to: buffer)

        buffer.write(elements: stringBytes)
    }
}

// MARK: - Position

extension Int64 {
    init(from bytes: UInt64, length: Int, rightOffset: Int) {
        let maxNumbers = NSDecimalNumber(decimal: pow(2, length))

        self = Int64((bytes >> rightOffset) & (maxNumbers.uint64Value - 1))
        if self > maxNumbers.int64Value / 2 {
            self -= maxNumbers.int64Value
        }
    }
}

public struct Position: CodableDataType, Equatable, Hashable {
    let x: Int
    let y: Int
    let z: Int

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

    public func encode<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        let uintX = UInt64(bitPattern: Int64(x))
        let uintY = UInt64(bitPattern: Int64(y))
        let uintZ = UInt64(bitPattern: Int64(z))

        let result = ((uintX & 0x3FFFFFF) << 38) | ((uintY & 0xFFF) << 26) | (uintZ & 0x3FFFFFF)
        result.encode(to: buffer)
    }
}
