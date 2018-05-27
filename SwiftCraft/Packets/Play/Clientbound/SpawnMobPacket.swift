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

    let entityID: EntityID
    let uuid: UUID
    let type: Int

    /// The location of the new entity.
    let location: EntityLocation

    /// The velocity of the new entity.
    let velocity: EntityVelocity

    let yaw: Byte
    let pitch: Byte
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
