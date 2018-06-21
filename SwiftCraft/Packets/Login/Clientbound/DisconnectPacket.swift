//
//  DisconnectPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Received when the server closes the connection while logging in.
///
/// - Note: The reason will be described in the `message` field.
public struct DisconnectPacket: DeserializablePacket, LoginPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x00
    }

    /// The message with a description of the reason.
    public let message: String

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        message = try String(from: buffer)
    }
}
