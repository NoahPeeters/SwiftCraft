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

    public static func blockChangeReactor(blockManager: BlockManager) -> Reactor {
        return ClosureReactor<BlockChangePacket> { packet, _ in
            blockManager.updateBlockID(at: packet.location, blockID: packet.blockID)
        }
    }

    public static func multiBlockChangeReactor(blockManager: BlockManager) -> Reactor {
        return ClosureReactor<MultiBlockChangePacket> { packet, _ in
            for (location, blockID) in packet.changes {
                blockManager.updateBlockID(at: location, blockID: blockID)
            }
        }
    }
}

public protocol BlockManager {
    /// Unloads the chunk at the specified location.
    ///
    /// - Parameter location: The location of the chunk to unload.
    func unloadChunk(at location: ChunkColumn.Position)

    /// Loads the chunk at the location if not preseant. Otherwise updates it.
    ///
    /// - Parameters:
    ///   - location: The location of the chunk.
    ///   - chunk: The chunk data.
    func loadOrUpdateChunk(at location: ChunkColumn.Position, chunk: ChunkColumn)

    /// Updates the block id of the block at the given locaation.
    ///
    /// - Parameters:
    ///   - location: The location of the block.
    ///   - blockID: THe new block id.
    func updateBlockID(at location: BlockPosition, blockID: BlockID)
}
