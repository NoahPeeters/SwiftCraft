//
//  EntityVelocityPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 27.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Updaes the veloxity of an entity.
public struct EntityVelocityPacket: DeserializablePacket, PlayPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x3E
    }

    /// The id of the entity.
    public let entityID: EntityID

    /// The new velocity of the entity.
    public let newVelocity: EntityVelocity

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        entityID = try VarInt32(from: buffer).value
        newVelocity = try EntityVelocity(from: buffer)
    }
}
