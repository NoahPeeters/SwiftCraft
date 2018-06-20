//
//  DestroyEntitiesPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 19.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Removes all entities with the given id from the world.
public struct DestroyEntitiesPacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .play, id: 0x32)
    }

    let entityIDs: [EntityID]

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        entityIDs = try [VarInt32](from: buffer).map { $0.value }
    }
}
