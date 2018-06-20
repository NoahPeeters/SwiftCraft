//
//  BlockChangePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 19.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Informs the client about a change of a block.
public struct BlockChangePacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .play, id: 0x0B)
    }

    /// The location of the block.
    let location: Position

    /// The new block id.
    let blockID: BlockID

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        location = try Position(from: buffer)
        blockID = try BlockID(rawValue: UInt16(VarInt32(from: buffer).value))
    }
}
