//
//  TeleportConfirmPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Answer to a PlayerPositionAndLookPacket
public struct TeleportConfirmPacket: BufferSerializablePacket, PlayPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x00
    }

    /// The teleportation id reveived from the server.
    public let teleportID: Int

    public func serializeData<Buffer: ByteWriteBuffer>(to buffer: Buffer, context: SerializationContext) {
        VarInt32(teleportID).serialize(to: buffer)
    }
}

extension MinecraftClient {
    public func sendTeleportConfirm(teleportID: Int) {
        sendPacket(TeleportConfirmPacket(teleportID: teleportID))
    }
}
