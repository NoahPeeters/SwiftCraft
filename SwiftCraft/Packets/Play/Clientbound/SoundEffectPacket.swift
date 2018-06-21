//
//  SoundEffectPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Tells the client to play a sound.
public struct SoundEffectPacket: DeserializablePacket, LoginPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x49
    }

    /// The id of the sound to play.
    public let soundID: Int

    /// The category of the sound.
    public let soundCategory: Int

    /// The x location of the effect.
    public let effectPositionX: Double

    /// The y location of the effect.
    public let effectPositionY: Double

    /// The z location of the effect.
    public let effectPositionZ: Double

    /// The volume of the sound (0.0 - 1.0)
    public let volume: Float

    /// The pitch of the sound (0.5 - 2.0)
    public let pitch: Float

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        soundID = try VarInt32(from: buffer).integer
        soundCategory = try VarInt32(from: buffer).integer

        effectPositionX = try Double(Int32(from: buffer)) / 8
        effectPositionY = try Double(Int32(from: buffer)) / 8
        effectPositionZ = try Double(Int32(from: buffer)) / 8

        volume = try Float(from: buffer)
        pitch = try Float(from: buffer)
    }
}
