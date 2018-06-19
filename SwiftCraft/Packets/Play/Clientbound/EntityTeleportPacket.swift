//
//  EntityTeleportPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 19.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Updates the location and look direction of an entity.
public struct EntityTeleportPacket: SimpleDeserializablePacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x4C)

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

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        entityID = try VarInt32(from: buffer).value
        x = try Double(from: buffer)
        y = try Double(from: buffer)
        z = try Double(from: buffer)
        yaw = try Angle(from: buffer)
        pitch = try Angle(from: buffer)
        isOnGround = try Bool(from: buffer)
    }
}
