//
//  UnloadChunkPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 27.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Tells the client to unload a chunk
public struct UnloadChunkPacket: SimpleDeserializablePacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x1D)

    public let location: ChunkColumn.Location

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        location = try ChunkColumn.Location(
            x: Int(Int32(from: buffer)),
            z: Int(Int32(from: buffer)))
    }
}
