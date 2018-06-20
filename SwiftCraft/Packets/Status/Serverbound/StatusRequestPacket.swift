//
//  StatusRequestPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// The packet to send after receiveing a keepalive packet from the server.
public struct StatusRequestPacket: BufferSerializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .status, id: 0x00)
    }

    public func serializeData<Buffer: ByteWriteBuffer>(to buffer: Buffer, context: SerializationContext) {
        // Nothing todo. THis packet is empty.
    }
}

extension MinecraftClient {
    /// Sends a keepalive packet to the server.
    /// This must be send after receiving a keepalive request or the client will be kicked.
    ///
    /// - Parameter id: The id from the received keepalive packet.
    public func sendStatusRequestPacket() {
        sendPacket(StatusRequestPacket())
    }
}
