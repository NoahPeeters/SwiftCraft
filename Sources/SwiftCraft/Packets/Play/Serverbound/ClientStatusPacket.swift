//
//  ClientStatusPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Sends a status update to the server.
public struct ClientStatusPacket: BufferSerializablePacket, PlayPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x03
    }

    /// The action id of the packet. Send 0 to perform respawn and 1 for a statistics request.
    public let actionID: Int32

    public func serializeData<Buffer: ByteWriteBuffer>(to buffer: Buffer, context: SerializationContext) {
        VarInt32(actionID).serialize(to: buffer)
    }
}

extension MinecraftClient {
    public func performRespawn() {
        sendPacket(ClientStatusPacket(actionID: 0))
    }

    public func requestStatistics() {
        sendPacket(ClientStatusPacket(actionID: 1))
    }
}
