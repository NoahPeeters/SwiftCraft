//
//  EntityTeleportPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 19.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Updates the location and look direction of an entity.
public struct EntityTeleportPacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .play, id: 0x4C)
    }

    /// The id of the entity.
    public let entityID: EntityID

    /// The new x location.
    public let x: Double

    /// The new y location.
    public let y: Double

    /// The new z location.
    public let z: Double

    /// The new yaw angle.
    public let yaw: Angle

    /// The new pitch angle.
    public let pitch: Angle

    /// A flag whether the entity touches the ground.
    public let isOnGround: Bool

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        entityID = try VarInt32(from: buffer).value
        x = try Double(from: buffer)
        y = try Double(from: buffer)
        z = try Double(from: buffer)
        yaw = try Angle(from: buffer)
        pitch = try Angle(from: buffer)
        isOnGround = try Bool(from: buffer)
    }
}
