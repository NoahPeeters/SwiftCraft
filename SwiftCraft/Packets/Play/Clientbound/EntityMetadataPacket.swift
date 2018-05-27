//
//  EntityMetadataPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 27.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Updates the metadata of an entity.
public struct EntityMetadataPacket: SimpleDeserializablePacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x3C)

    /// The id of the entity.
    public let entityID: EntityID

    /// The new metadata. Currently not decoded.
    public let metadata: ByteArray

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        entityID = try VarInt32(from: buffer).value
        metadata = buffer.readRemainingElements()
    }
}
