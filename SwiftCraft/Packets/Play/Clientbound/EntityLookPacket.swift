//
//  EntityLookPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 19.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Updates the look direction of an entity.
public struct EntityLookPacket: SimpleDeserializablePacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x28)

    /// The id of the entity.
    public let entityID: EntityID

    /// The new yaw angle.
    public let yaw: Angle

    /// The new pitch angle.
    public let pitch: Angle

    /// A flag whether the entity touches the ground.
    public let isOnGround: Bool

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        entityID = try VarInt32(from: buffer).value
        yaw = try Angle(from: buffer)
        pitch = try Angle(from: buffer)
        isOnGround = try Bool(from: buffer)
    }
}
