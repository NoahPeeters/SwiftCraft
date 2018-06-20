//
//  UpdateBlockEntityPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Updates data of a block entity
public struct UpdateBlockEntityPacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .play, id: 0x09)
    }

    /// The location of the block.
    public let location: Position

    /// The action to perform.
    public let action: Byte

    /// The data to apply.
    public let data: NBT

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        location = try Position(from: buffer)
        action = try Byte(from: buffer)
        data = try NBT(from: buffer)
    }
}
