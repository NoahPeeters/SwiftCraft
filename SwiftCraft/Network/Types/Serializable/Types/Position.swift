//
//  Position.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// A minecraft position struct.
public struct Position: Serializable, Hashable {
    /// The x position.
    let x: Int

    /// The y position.
    let y: Int

    /// The z position.
    let z: Int

    var chunkX: Int {
        return chunkLocation(x)
    }

    var chunkY: Int {
        return chunkLocation(y)
    }

    var chunkZ: Int {
        return chunkLocation(z)
    }

    var xInChunk: Int {
        return relativeLocationInChunk(x)
    }

    var yInChunk: Int {
        return relativeLocationInChunk(y)
    }

    var zInChunk: Int {
        return relativeLocationInChunk(z)
    }

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

private func relativeLocationInChunk(_ value: Int) -> Int {
    if value >= 0 {
        return value.remainderReportingOverflow(dividingBy: 16).partialValue
    } else {
        return 15 - (-1 - value).remainderReportingOverflow(dividingBy: 16).partialValue
    }
}

private func chunkLocation(_ value: Int) -> Int {
    if value >= 0 {
        return value / 16
    } else {
        return (value - 15) / 16
    }
}
