//
//  SpawnPlayerPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Tells the client to spawn a player.
public struct SpawnPlayerPacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .play, id: 0x05)
    }

    /// The id of the player entity.
    let entityID: EntityID

    /// The uuid of the player.
    let playerUUID: UUID

    /// The location of the player.
    let location: EntityLocation

    /// The yaw of the player.
    let yaw: Angle

    /// The pitch of the player
    let pitch: Angle

    /// Additional metadata.
    let metaData: ByteArray

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        entityID = try VarInt32(from: buffer).value
        playerUUID = try UUID(from: buffer)
        location = try EntityLocation(from: buffer)
        yaw = try Angle(from: buffer)
        pitch = try Angle(from: buffer)
        metaData = buffer.readRemainingElements()
        print(self)
    }
}
