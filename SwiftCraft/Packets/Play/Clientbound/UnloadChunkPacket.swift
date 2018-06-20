//
//  UnloadChunkPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 27.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Tells the client to unload a chunk
public struct UnloadChunkPacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .play, id: 0x1D)
    }

    public let location: ChunkColumn.Location

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        location = try ChunkColumn.Location(
            x: Int(Int32(from: buffer)),
            z: Int(Int32(from: buffer)))
    }
}
