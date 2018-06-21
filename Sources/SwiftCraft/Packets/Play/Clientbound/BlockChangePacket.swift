//
//  BlockChangePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 19.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Informs the client about a change of a block.
public struct BlockChangePacket: DeserializablePacket, PlayPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x0B
    }

    /// The location of the block.
    public let location: BlockPosition

    /// The new block id.
    public let blockID: BlockID

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        location = try BlockPosition(from: buffer)
        blockID = try BlockID(rawValue: UInt16(VarInt32(from: buffer).value))
    }
}
