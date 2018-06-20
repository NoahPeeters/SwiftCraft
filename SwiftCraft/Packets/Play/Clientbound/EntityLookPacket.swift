//
//  EntityLookPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 19.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Updates the look direction of an entity.
public struct EntityLookPacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID {
        return PacketID(connectionState: .play, id: 0x28)
    }

    /// The id of the entity.
    public let entityID: EntityID

    /// The new yaw angle.
    public let yaw: Angle

    /// The new pitch angle.
    public let pitch: Angle

    /// A flag whether the entity touches the ground.
    public let isOnGround: Bool

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        entityID = try VarInt32(from: buffer).value
        yaw = try Angle(from: buffer)
        pitch = try Angle(from: buffer)
        isOnGround = try Bool(from: buffer)
    }
}
