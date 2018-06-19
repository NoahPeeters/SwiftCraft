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

    public struct Location: Hashable {
        public let x: Int
        public let z: Int
    }

}
