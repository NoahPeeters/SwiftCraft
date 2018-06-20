//
//  BlockBreakAnimationPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Tells the client to show a block break animation.
public struct BlockBreakAnimationPacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .play, id: 0x08)
    }

    /// The id of the entity breaking the block.
    public let entityID: EntityID

    /// The location of the block
    public let location: Position

    /// The stage of the animation (0 - 9 to set it, any other value to remove it)
    public let destroyStage: Byte

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        entityID = try VarInt32(from: buffer).value
        location = try Position(from: buffer)
        destroyStage = try Byte(from: buffer)
    }
}
