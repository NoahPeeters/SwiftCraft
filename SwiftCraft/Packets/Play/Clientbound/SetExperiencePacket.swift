//
//  SetExperiencePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 27.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Sets the experience of the player.
public struct SetExperiencePacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .play, id: 0x40)
    }

    /// The current position of the experience bar. (0-1)
    let experienceBar: Float

    /// The level of the player.
    let level: Int

    /// The total experience of the player.
    /// [More information](https://minecraft.gamepedia.com/g00/Experience?i10c.encReferrer=&i10c.ua=4#Leveling_up)
    let totalExperience: Int

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        experienceBar = try Float(from: buffer)
        level = try VarInt32(from: buffer).integer
        totalExperience = try VarInt32(from: buffer).integer
    }
}
