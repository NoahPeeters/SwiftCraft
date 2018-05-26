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
public struct DisconnectPacket: ReceivedPacket {
    public static var packetID = PacketID(connectionState: .login, id: 0x00)

    /// The message with a description of the reason.
    public let message: String

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        message = try String(from: buffer)
    }
}
