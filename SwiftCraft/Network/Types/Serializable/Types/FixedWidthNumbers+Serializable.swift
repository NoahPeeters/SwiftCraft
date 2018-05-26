//
//  FixedWidthNumbers+Serializable.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
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
