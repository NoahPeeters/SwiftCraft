//
//  EffectPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Plays an effect.
public struct EffectPacket: DeserializablePacket, PlayPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x21
    }

    /// The id of the effect.
    public let effectID: Int

    /// The location of the effect.
    public let location: BlockPosition

    /// Additional data used for some effects.
    public let data: Int

    /// Disables the relative volume calculation.
    public let disableRelativeVolume: Bool

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        effectID = try Int(Int32(from: buffer))
        location = try BlockPosition(from: buffer)
        data = try Int(Int32(from: buffer))
        disableRelativeVolume = try Bool(from: buffer)
    }
}
