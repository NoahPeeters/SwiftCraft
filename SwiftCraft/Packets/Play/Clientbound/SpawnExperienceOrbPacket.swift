//
//  SpawnExperienceOrbPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Send by the server when a experience orb spawns
public struct SpawnExperienceOrbPacket: SimpleDeserializablePacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x01)

    /// The id of the new experience orb.
    let entityID: EntityID

    /// The location of the new xp orb.
    let location: EntityLocation

    /// The amount of experience this orb will reward once collected
    let amount: Int16

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        entityID = try EntityID(VarInt32(from: buffer).value)
        location = try EntityLocation(
            x: Double(from: buffer),
            y: Double(from: buffer),
            z: Double(from: buffer))
        amount = try Int16(from: buffer)
    }
}
