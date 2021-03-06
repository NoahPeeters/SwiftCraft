//
//  SendChatMessagePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// A packet which will send a chat message to the server.
public struct SendChatMessagePacket: BufferSerializablePacket, PlayPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x02
    }

    /// The chat message to send.
    ///
    /// - Note: Most servers will interpret a message with a leading / as a command.
    public let message: String

    public func serializeData<Buffer: ByteWriteBuffer>(to buffer: Buffer, context: SerializationContext) {
        message.serialize(to: buffer)
    }
}

extension MinecraftClient {
    /// Sends a chat message to the server. A normal server will forward this chat message to every player.
    ///
    /// - Parameter message: The message to send.
    public func sendMessage(_ message: String) {
        sendPacket(SendChatMessagePacket(message: message))
    }
}
