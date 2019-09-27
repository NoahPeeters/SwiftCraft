//
//  PlayerPositionPacket.swift
//  SwiftCraft iOS
//
//  Created by Noah Peeters on 24.07.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Updates the players location.
public struct PlayerPositionPacket: BufferSerializablePacket, PlayPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x0D
    }

    /// The new x location of the player.
    public let x: Double

    /// The new feet y location of the player.
    public let feetY: Double

    /// The new z location of the player.
    public let z: Double

    // Flag whether the player stands on the ground.
    public let isOnGround: Bool

    public func serializeData<Buffer: ByteWriteBuffer>(to buffer: Buffer, context: SerializationContext) {
        x.serialize(to: buffer)
        feetY.serialize(to: buffer)
        z.serialize(to: buffer)
        isOnGround.serialize(to: buffer)
    }
}

extension MinecraftClient {
    public func sendPlayerPosition(x: Double, feetY: Double, z: Double, isOnGround: Bool) {
        sendPacket(PlayerPositionPacket(x: x, feetY: feetY, z: z, isOnGround: isOnGround))
    }
}
