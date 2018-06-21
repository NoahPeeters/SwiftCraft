//
//  UnloadChunkPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 27.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Tells the client to unload a chunk
public struct UnloadChunkPacket: DeserializablePacket, LoginPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x1D
    }

    public let location: ChunkColumn.Position

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        location = try ChunkColumn.Position(
            x: Int(Int32(from: buffer)),
            z: Int(Int32(from: buffer)))
    }
}
