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

extension FixedWidthInteger {
    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        let bigEndian: Self = try buffer.loadAsType()
        self.init(bigEndian: bigEndian)
    }

    public func serialize<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        buffer.saveRawCopy(self.bigEndian)
    }
}

extension Int8: Serializable {}
extension UInt8: Serializable {}
extension Int16: Serializable {}
extension UInt16: Serializable {}
extension Int32: Serializable {}
extension UInt32: Serializable {}
extension Int64: Serializable {}
extension UInt64: Serializable {}

// MARK: - Floating Point
extension Float: Serializable {
    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        self = try Float(bitPattern: UInt32(bigEndian: buffer.loadAsType()))
    }

    public func serialize<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        buffer.saveRawCopy(self.bitPattern.bigEndian)
    }
}

extension Double: Serializable {
    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        self = try Double(bitPattern: UInt64(bigEndian: buffer.loadAsType()))
    }

    public func serialize<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        buffer.saveRawCopy(self.bitPattern.bigEndian)
    }
}
