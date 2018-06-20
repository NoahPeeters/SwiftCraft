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
    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        self = try buffer.readOne() != 0x00
    }

    public func serialize<Buffer: ByteWriteBuffer>(to buffer: Buffer) {
        buffer.write(element: self ? 0x01 : 0x00)
    }
}

// MARK: - Integer
extension FixedWidthInteger {
    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        let bigEndian: Self = try buffer.loadAsType()
        self.init(bigEndian: bigEndian)
    }

    public func serialize<Buffer: ByteWriteBuffer>(to buffer: Buffer) {
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
    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        self = try Float(bitPattern: UInt32(bigEndian: buffer.loadAsType()))
    }

    public func serialize<Buffer: ByteWriteBuffer>(to buffer: Buffer) {
        buffer.saveRawCopy(self.bitPattern.bigEndian)
    }
}

extension Double: Serializable {
    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        self = try Double(bitPattern: UInt64(bigEndian: buffer.loadAsType()))
    }

    public func serialize<Buffer: ByteWriteBuffer>(to buffer: Buffer) {
        buffer.saveRawCopy(self.bitPattern.bigEndian)
    }
}
