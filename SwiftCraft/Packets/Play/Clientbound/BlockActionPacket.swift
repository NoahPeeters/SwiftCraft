//
//  BlockActionPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Perfroms an action of a block.
public struct BlockActionPacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .play, id: 0x0A)
    }

    /// The location of the block.
    public let location: Position

    /// The action to perfrom.
    public let action: Byte

    /// A additional parameter of the action.
    public let param: Byte

    /// The block type.
    public let blockType: Int

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        location = try Position(from: buffer)
        action = try Byte(from: buffer)
        param = try Byte(from: buffer)
        blockType = try VarInt32(from: buffer).integer
    }
}
