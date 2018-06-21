//
//  SpawnMobPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 27.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Spawns a new mob in the world
public struct SpawnMobPacket: DeserializablePacket, PlayPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x03
    }

    /// The id of the entity.
    public let entityID: EntityID

    /// The uuid of the entity.
    public let uuid: UUID

    /// The type of the entity.
    public let type: Int

    /// The location of the new entity.
    public let location: EntityLocation

    /// The velocity of the new entity.
    public let velocity: EntityVelocity

    /// The yaw of the entity.
    public let yaw: Byte

    /// The pitch of the entity.
    public let pitch: Byte

    /// The head pitch of the entity.
    public let headPitch: Byte

    /// Additional metadata.
    public let metaData: ByteArray

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        entityID = try VarInt32(from: buffer).value
        uuid = try UUID(from: buffer)
        type = try VarInt32(from: buffer).integer
        location = try EntityLocation(from: buffer)
        yaw = try Byte(from: buffer)
        pitch = try Byte(from: buffer)
        headPitch = try Byte(from: buffer)
        velocity = try EntityVelocity(from: buffer)
        metaData = buffer.readRemainingElements()
    }
}
