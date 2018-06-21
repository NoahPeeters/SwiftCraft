//
//  World.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 27.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// A class to save the state of the minecraft world.
public class MinecraftWorld {
    /// The chunks which are loaded at the moment.
    public private(set) var chunkData: [ChunkColumn.Position: ChunkColumn] = [:]

    public private(set) var entities: [Entity] = []

    public let playerEntity: Entity

    /// Creates a new minecarft world.
    public init() {
        playerEntity = Entity()
    }
}

extension MinecraftWorld: BlockManager {
    public func unloadChunk(at location: ChunkColumn.Position) {
        chunkData.removeValue(forKey: location)
    }

    public func loadOrUpdateChunk(at location: ChunkColumn.Position, chunk: ChunkColumn) {
        if let existingChunkColumn = chunkData[location] {
            existingChunkColumn.updateWith(chunk)
        } else {
            chunkData[location] = chunk
        }
    }

    public func updateBlockID(at location: BlockPosition, blockID: BlockID) {
        let chunkLocation = ChunkColumn.Position(block: location)

        guard let chunk = chunkData[chunkLocation]?.chunk(forBlock: location) else {
            // Ignore chunk updates in unloaded chunks
            return
        }

        let blockIndex = chunk.blockIndex(block: location)
        chunk.setBlockID(blockIndex: blockIndex, newValue: blockID)
    }

    public func getBlockID(at location: BlockPosition) -> BlockID? {
        let chunkLocation = ChunkColumn.Position(block: location)

        guard let chunk = chunkData[chunkLocation]?.chunk(forBlock: location) else {
            return nil
        }

        let blockIndex = chunk.blockIndex(block: location)
        return chunk.getBlockID(blockIndex: blockIndex)
    }
}

extension MinecraftWorld: PlayerManager {}
