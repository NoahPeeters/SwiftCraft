//
//  SpawnGlobalEntityPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Tells the client to spawn a global entity. Currently the only global entity is the thunderbolt strikes.
public struct SpawnGlobalEntityPacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .play, id: 0x02)
    }

    /// The id of the entity.
    public let entityID: EntityID

    /// The type of the entity.
    public let type: Int

    /// The location of the new entity.
    public let location: EntityLocation

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        entityID = try VarInt32(from: buffer).value
        type = try Int(Byte(from: buffer))
        location = try EntityLocation(from: buffer)
    }
}
