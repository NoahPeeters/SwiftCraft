//
//  MultiBlockChangePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// A packet received if multiple blocks changed in the same chunk in the same tick.
public struct MultiBlockChangePacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .play, id: 0x10)
    }

    /// List of block changes
    public let changes: [(Position, BlockID)]

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        let chunkX = try Int(Int32(from: buffer))
        let chunkZ = try Int(Int32(from: buffer))

        let blockChangeCount = try VarInt32(from: buffer)

        changes = try (0..<blockChangeCount.value).map { _ in
            let horrizontalPosition = try Byte(from: buffer)
            let y = try Int(Byte(from: buffer))
            let blockID = try VarInt32(from: buffer)

            let x = chunkX * 16 + Int((horrizontalPosition & 0xF0) >> 4)
            let z = chunkZ * 16 + Int((horrizontalPosition & 0x0F))

            return (Position(x: x, y: y, z: z), BlockID(rawValue: UInt16(blockID.value)))
        }
    }
}
