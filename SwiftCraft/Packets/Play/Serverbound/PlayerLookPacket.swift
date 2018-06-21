//
//  PlayerLookPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Updates the players look direction
public struct PlayerLookPacket: BufferSerializablePacket, PlayPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x0F
    }

    /// The new yaw of the player.
    public let yaw: Float

    /// The new pitch of the player.
    public let pitch: Float

    // Flag whether the player stands on the ground.
    public let isOnGround: Bool

    public func serializeData<Buffer: ByteWriteBuffer>(to buffer: Buffer, context: SerializationContext) {
        yaw.serialize(to: buffer)
        pitch.serialize(to: buffer)
        isOnGround.serialize(to: buffer)
    }
}

extension MinecraftClient {
    public func sendPlayerLook(yaw: Float, pitch: Float, isOnGround: Bool) {
        sendPacket(PlayerLookPacket(yaw: yaw, pitch: pitch, isOnGround: isOnGround))
    }
}
