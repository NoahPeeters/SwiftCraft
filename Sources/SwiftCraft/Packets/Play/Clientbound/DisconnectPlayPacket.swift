//
//  DisconnectPlayPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 28.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Received when the server closes the connection while playing in.
///
/// - Note: The reason will be described in the `message` field.
public struct DisconnectPlayPacket: DeserializablePacket, PlayPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x1A
    }

    /// The message with a description of the reason.
    public let message: ChatMessage

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        message = try ChatMessage(from: buffer)
    }
}
