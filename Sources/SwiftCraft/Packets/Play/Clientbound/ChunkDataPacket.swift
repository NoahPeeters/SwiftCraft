//
//  ChunkDataPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Packet containing the chunk data.
public struct ChunkDataPacket: DeserializablePacket, PlayPacketIDProvider, CustomStringConvertible {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x20
    }

    public let location: ChunkColumn.Position
    public let chunkColumn: ChunkColumn

    public var description: String {
        return "ChunkDataPacket(x: \(location.x), z: \(location.z))"
    }

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        location = try ChunkColumn.Position(
            x: Int(Int32(from: buffer)),
            z: Int(Int32(from: buffer)))

        let isInitial = try Bool(from: buffer)

        let primaryBitMask = try VarInt32(from: buffer)
        _ = try VarInt32(from: buffer)

        let chunkSections: [ChunkSection?] = try (0..<16).map { yOffset in
            guard (primaryBitMask.integer >> yOffset) & 1 != 0 else {
                return nil
            }

            return try ChunkSection(from: buffer, hasSkylight: context.client.dimension.hasSkylight)
        }

        let biomes = try isInitial ? buffer.read(lenght: 256) : nil

        chunkColumn = ChunkColumn(chunkSections: chunkSections, biomes: biomes)
        print(self)
    }
}
