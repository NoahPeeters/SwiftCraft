//
//  KeepaliveResponsePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// The packet to send after receiveing a keepalive packet from the server.
public struct KeepaliveResponsePacket: BufferSerializablePacket, PlayPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x0B
    }

    /// The id from the received keepalive packet.
    public let id: Int64

    public func serializeData<Buffer: ByteWriteBuffer>(to buffer: Buffer, context: SerializationContext) {
        id.serialize(to: buffer)
    }
}

extension MinecraftClient {
    /// Sends a keepalive packet to the server.
    /// This must be send after receiving a keepalive request or the client will be kicked.
    ///
    /// - Parameter id: The id from the received keepalive packet.
    public func sendKeepaliveResponsePacket(id: Int64) {
        sendPacket(KeepaliveResponsePacket(id: id))
    }
}
