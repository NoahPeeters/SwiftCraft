//
//  EntityMetadataPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 27.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Updates the metadata of an entity.
public struct EntityMetadataPacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .play, id: 0x3C)
    }

    /// The id of the entity.
    public let entityID: EntityID

    /// The new metadata. Currently not decoded.
    public let metadata: ByteArray

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        entityID = try VarInt32(from: buffer).value
        metadata = buffer.readRemainingElements()
    }
}
