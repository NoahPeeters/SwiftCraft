//
//  KeepaliveRequestPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// A packet send in regular time intervalls to request a confirmation that the connection is still alive.
///
/// - Attention: Every client must handle this packet or it will be kicked
public struct KeepaliveRequestPacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID {
        return PacketID(connectionState: .play, id: 0x1F)
    }

    /// An id which must be used in the reply.
    public let id: Int64

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        id = try Int64(from: buffer)
    }
}
