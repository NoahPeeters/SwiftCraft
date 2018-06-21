//
//  SpawnExperienceOrbPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Send by the server when a experience orb spawns
public struct SpawnExperienceOrbPacket: DeserializablePacket, LoginPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x01
    }

    /// The id of the new experience orb.
    public let entityID: EntityID

    /// The location of the new xp orb.
    public let location: EntityLocation

    /// The amount of experience this orb will reward once collected
    public let amount: Int16

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        entityID = try EntityID(VarInt32(from: buffer).value)
        location = try EntityLocation(from: buffer)
        amount = try Int16(from: buffer)
    }
}
