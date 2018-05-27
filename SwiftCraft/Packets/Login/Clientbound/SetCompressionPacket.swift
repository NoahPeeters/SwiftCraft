//
//  SetCompressionPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 22.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Packet to enable or disable compression
public struct SetCompressionPacket: SimpleDeserializablePacket {
    public static var packetID = PacketID(connectionState: .login, id: 0x03)

    /// The threshold describes how large a packet must be to be compressed.
    ///
    /// - Attention:
    ///     When compressing a packet which is smaller then the threshold of the last
    ///     `SetCompressionPacket` received the connection will be closed by the server.
    public let threshold: Int

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        threshold = try VarInt32(from: buffer).integer
    }
}
