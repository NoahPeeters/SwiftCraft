//
//  EntityLookAndRelativeMovePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 19.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Updates the location and look direction of an entity.
public struct EntityLookAndRelativeMovePacket: SimpleDeserializablePacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x27)

    /// The id of the entity.
    public let entityID: EntityID

    /// The relative x movement of the entity. `(current * 32 - prev * 32) * 128`.
    ///
    /// - Attention: Use deltaX for double value.
    public let deltaXRaw: Int16

    /// The relative y movement of the entity. `(current * 32 - prev * 32) * 128`.
    ///
    /// - Attention: Use deltaY for double value.
    public let deltaYRaw: Int16

    /// The relative z movement of the entity. `(current * 32 - prev * 32) * 128`.
    ///
    /// - Attention: Use deltaZ for double value.
    public let deltaZRaw: Int16

    /// The new yaw angle.
    public let yaw: Angle

    /// The new pitch angle.
    public let pitch: Angle

    /// A flag whether the entity touches the ground.
    public let isOnGround: Bool

    /// The relative x movement of the entity.
    public var deltaX: Double {
        return Double(deltaXRaw) / (128 * 32)
    }

    /// The relative x movement of the entity.
    public var deltaY: Double {
        return Double(deltaYRaw) / (128 * 32)
    }

    /// The relative x movement of the entity.
    public var deltaZ: Double {
        return Double(deltaYRaw) / (128 * 32)
    }

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        entityID = try VarInt32(from: buffer).value
        deltaXRaw = try Int16(from: buffer)
        deltaYRaw = try Int16(from: buffer)
        deltaZRaw = try Int16(from: buffer)
        yaw = try Angle(from: buffer)
        pitch = try Angle(from: buffer)
        isOnGround = try Bool(from: buffer)
    }
}
