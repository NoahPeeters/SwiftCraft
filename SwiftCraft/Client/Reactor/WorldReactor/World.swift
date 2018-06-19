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
    private(set) public var chunkData: [ChunkColumn.Location: ChunkColumn] = [:]

    /// Creates a new minecarft world.
    public init() {

    }
}

extension MinecraftWorld: BlockManager {
    public func unloadChunk(at location: ChunkColumn.Location) {
        chunkData.removeValue(forKey: location)
    }

    public func loadOrUpdateChunk(at location: ChunkColumn.Location, chunk: ChunkColumn) {
        if let existingChunkColumn = chunkData[location] {
            existingChunkColumn.updateWith(chunk)
        } else {
            chunkData[location] = chunk
        }
    }

    public func updateBlockID(at location: Position, blockID: BlockID) {
        let chunkLocation = ChunkColumn.Location(block: location)

        guard let chunk = chunkData[chunkLocation]?.chunk(forBlock: location) else {
            // Ignore chunk updates in unloaded chunks
            return
        }

        let blockIndex = chunk.blockIndex(block: location)
        chunk.setBlockID(blockIndex: blockIndex, newValue: blockID)
    }
}
