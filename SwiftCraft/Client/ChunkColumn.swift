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

    func updateWith(_ other: ChunkColumn) {
        for index in 0..<16 {
            if let newChunkSection = other.chunkSections[index] {
                chunkSections[index] = newChunkSection
            }
        }
    }

    func chunk(withIndex index: Int) -> ChunkSection? {
        return chunkSections[index]
    }

    func chunk(forBlock block: Position) -> ChunkSection? {
        return chunk(withIndex: block.chunkY)
    }

    public struct Location: Hashable {
        public let x: Int
        public let z: Int

        init(x: Int, z: Int) {
            self.x = x
            self.z = z
        }

        init(block: Position) {
            self.init(x: block.chunkX, z: block.chunkY)
        }
    }
}
