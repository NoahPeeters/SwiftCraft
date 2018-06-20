//
//  SpawnObjectPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 27.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Spawns a new object in the world.
public struct SpawnObjectPacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .play, id: 0x00)
    }

    /// The id of the object.
    public let entityID: EntityID

    /// The uuid of the object.
    public let uuid: UUID

    /// The type of the object.
    public let type: Byte

    /// The location of the new object.
    public let location: EntityLocation

    /// The velocity of the new object.
    public let velocity: EntityVelocity

    /// The pitch of the object.
    public let pitch: Byte

    /// The yaw of the object.
    public let yaw: Byte

    /// Custom data of the object.
    public let data: Int32

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        entityID = try VarInt32(from: buffer).value
        uuid = try UUID(from: buffer)
        type = try Byte(from: buffer)
        location = try EntityLocation(from: buffer)
        pitch = try Byte(from: buffer)
        yaw = try Byte(from: buffer)
        data = try Int32(from: buffer)
        velocity = try EntityVelocity(from: buffer)
    }
}
