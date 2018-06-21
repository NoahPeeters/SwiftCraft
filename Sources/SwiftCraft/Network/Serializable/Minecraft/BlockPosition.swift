//
//  BlockPosition.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// A minecraft block position struct.
public struct BlockPosition: Serializable, Hashable {
    /// The x position.
    public let x: Int

    /// The y position.
    public let y: Int

    /// The z position.
    public let z: Int

    /// The x position of the chunk containing the block.
    public var chunkX: Int {
        return chunkLocation(ofBlock: x)
    }

    /// The y position of the chunk containing the block.
    public var chunkY: Int {
        return chunkLocation(ofBlock: y)
    }

    /// The z position of the chunk containing the block.
    public var chunkZ: Int {
        return chunkLocation(ofBlock: z)
    }

    /// The x position of the block inside of its chunk.
    public var xInChunk: Int {
        return relativeLocationInChunk(ofBlock: x)
    }

    /// The y position of the block inside of its chunk.
    public var yInChunk: Int {
        return relativeLocationInChunk(ofBlock: y)
    }

    /// The z position of the block inside of its chunk.
    public var zInChunk: Int {
        return relativeLocationInChunk(ofBlock: z)
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

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        let data = try UInt64(from: buffer)

        self.init(
            x: Int(Int64(from: data, length: 26, rightOffset: 38)),
            y: Int(Int64(from: data, length: 12, rightOffset: 26)),
            z: Int(Int64(from: data, length: 26, rightOffset: 0)))
    }

    public func serialize<Buffer: ByteWriteBuffer>(to buffer: Buffer) {
        let uintX = UInt64(bitPattern: Int64(x))
        let uintY = UInt64(bitPattern: Int64(y))
        let uintZ = UInt64(bitPattern: Int64(z))

        let xComponent: UInt64 = ((uintX & 0x3FFFFFF) << 38)
        let yComponent: UInt64 = ((uintY & 0xFFF) << 26)
        let zComponent: UInt64 = (uintZ & 0x3FFFFFF)

        let result: UInt64 = xComponent | yComponent | zComponent
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
    public init(from bytes: UInt64, length: Int, rightOffset: Int) {
        let maxNumbers = NSDecimalNumber(decimal: pow(2, length))

        self = Int64((bytes >> rightOffset) & (maxNumbers.uint64Value - 1))
        if self > maxNumbers.int64Value / 2 {
            self -= maxNumbers.int64Value
        }
    }
}

/// Caclulates the offset of a block in its chunk.
///
/// - Parameter value: The block position.
/// - Returns: The position in the chunk.
private func relativeLocationInChunk(ofBlock value: Int) -> Int {
    if value >= 0 {
        return value.remainderReportingOverflow(dividingBy: 16).partialValue
    } else {
        return 15 - (-1 - value).remainderReportingOverflow(dividingBy: 16).partialValue
    }
}

/// Caclulates the position of the chunk containing the given block.
///
/// - Parameter value: The position of the block
/// - Returns: The position of the chunk.
private func chunkLocation(ofBlock value: Int) -> Int {
    if value >= 0 {
        return value / 16
    } else {
        return (value - 15) / 16
    }
}
