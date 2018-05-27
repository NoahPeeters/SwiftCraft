//
//  BlockReactor.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 27.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

extension MinecraftClient {
    /// Creates a new reactor to handle chunk data packets.
    ///
    /// - Parameter blockManger: The chunk manager to store the chunks to.
    /// - Returns: The reactor.
    public static func chunkDataReactor(blockManager: BlockManager) -> Reactor {
        return ClosureReactor<ChunkDataPacket> { packet, _ in
            blockManager.loadOrUpdateChunk(at: packet.location, chunk: packet.chunkColumn)
        }
    }

    /// Creates a new reactor to handle unload chunk packets.
    ///
    /// - Parameter blockManager: The chunk manager to store the chunks to.
    /// - Returns: The reactor.
    public static func unloadChunkReactor(blockManager: BlockManager) -> Reactor {
        return ClosureReactor<UnloadChunkPacket> { packet, _ in
            blockManager.unloadChunk(at: packet.location)
        }
    }
}

public protocol BlockManager {
    /// Unloads the chunk at the specified location.
    ///
    /// - Parameter location: The location of the chunk to unload.
    func unloadChunk(at location: ChunkColumn.Location)

    /// Loads the chunk at the location if not preseant. Otherwise updates it.
    ///
    /// - Parameters:
    ///   - location: The location of the chunk.
    ///   - chunk: The chunk data.
    func loadOrUpdateChunk(at location: ChunkColumn.Location, chunk: ChunkColumn)
}
