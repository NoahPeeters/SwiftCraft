//
//  SpawnPositionPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 19.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Sends the spawn location to the client.
public struct SpawnPositionPacket: DeserializablePacket, PlayPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x46
    }

    /// The spawn location. The compass will point to this location
    public let location: BlockPosition

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        location = try BlockPosition(from: buffer)
    }
}
