//
//  SpawnMobPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 27.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Spawns a new mob in the world
public struct SpawnMobPacket: SimpleDeserializablePacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x03)

    /// The id of the entity.
    let entityID: EntityID

    /// The uuid of the entity.
    let uuid: UUID

    /// The type of the entity.
    let type: Int

    /// The location of the new entity.
    let location: EntityLocation

    /// The velocity of the new entity.
    let velocity: EntityVelocity

    /// The yaw of the entity.
    let yaw: Byte

    /// The pitch of the entity.
    let pitch: Byte

    /// The head pitch of the entity.
    let headPitch: Byte

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        entityID = try VarInt32(from: buffer).value
        uuid = try UUID(from: buffer)
        type = try VarInt32(from: buffer).integer
        location = try EntityLocation(from: buffer)
        yaw = try Byte(from: buffer)
        pitch = try Byte(from: buffer)
        headPitch = try Byte(from: buffer)
        velocity = try EntityVelocity(from: buffer)
    }
}
