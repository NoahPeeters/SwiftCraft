//
//  PluginMessageReceivedPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Packet send to transmitt plugin message.
public struct PluginMessageReceivedPacket: SimpleDeserializablePacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x18)

    /// The string identifying the channel.
    ///
    /// - Note: Minecraft internal channels are prefixed with "MC|".
    public let channel: String

    /// The data send over the channel.
    public let data: ByteArray

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        channel = try String(from: buffer)
        data = buffer.readRemainingElements()
    }
}
