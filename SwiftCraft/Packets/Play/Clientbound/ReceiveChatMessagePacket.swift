//
//  ReceiveChatMessagePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Packet containing a new chat message received from the server.
public struct ReceiveChatMessagePacket: DeserializablePacket, LoginPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x0F
    }

    /// The message received from the server.
    public let message: String

    /// The location to show the message.
    public let position: ChatMessageLocation

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        message = try String(from: buffer)
        position = try ChatMessageLocation(rawValue: Byte(from: buffer)).unwrap(ChatMessagePacketError.unknownPosition)
    }
}

/// A error which can occure while deserializing a chat message packet.
public enum ChatMessagePacketError: Error {
    /// The received position is unknown.
    case unknownPosition
}
