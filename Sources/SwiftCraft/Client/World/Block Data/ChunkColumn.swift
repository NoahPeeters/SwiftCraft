//
//  ChunkColumn.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 27.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

public class ChunkColumn {
    private(set) public var chunkSections: [ChunkSection?]
    public let biomes: ByteArray?

    public init(chunkSections: [ChunkSection?], biomes: ByteArray?) {
        self.chunkSections = chunkSections
        self.biomes = biomes
    }

    public func updateWith(_ other: ChunkColumn) {
        for index in 0..<16 {
            if let newChunkSection = other.chunkSections[index] {
                chunkSections[index] = newChunkSection
            }
        }
    }

    public func chunk(withIndex index: Int) -> ChunkSection? {
        return chunkSections[index]
    }

    public func chunk(forBlock block: BlockPosition) -> ChunkSection? {
        return chunk(withIndex: block.chunkY)
    }

    public struct Position: Hashable {
        public let x: Int
        public let z: Int

        public init(x: Int, z: Int) {
            self.x = x
            self.z = z
        }

        public init(block: BlockPosition) {
            self.init(x: block.chunkX, z: block.chunkZ)
        }
    }
}
