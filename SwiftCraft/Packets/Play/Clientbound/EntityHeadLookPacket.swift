//
//  EntityHeadLookPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 19.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Updates the head look direction of an entity.
public struct EntityHeadLookPacket: DeserializablePacket, LoginPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x36
    }

    /// The id of the entity.
    public let entityID: EntityID

    /// The new angle.
    public let yaw: Angle

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        entityID = try VarInt32(from: buffer).value
        yaw = try Angle(from: buffer)
    }
}
