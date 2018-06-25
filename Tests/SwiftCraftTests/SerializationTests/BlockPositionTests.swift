//
//  BlockPositionTests.swift
//  SwiftCraftTests
//
//  Created by Noah Peeters on 25.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Quick
import Nimble
@testable import SwiftCraft

public class BlockPositionTests: QuickSpec {
    private static let position = BlockPosition(x: -15, y: 42, z: 188)
    private static let positionData: ByteArray = [
        0b11111111, 0b11111111, 0b11111100, 0b01000000,
        0b10101000, 0b00000000, 0b00000000, 0b10111100
    ]

    public override func spec() {
        it("correctly serializes a position") {
            expect(BlockPositionTests.position.directSerialized())
                .to(equal(BlockPositionTests.positionData))
        }

        it("correctly deserializes a position") {
            expect(try? BlockPosition(from: BlockPositionTests.positionData))
                .to(equal(BlockPositionTests.position))
        }

        it("calculates the chunk x position correctly") {
            expect(BlockPositionTests.position.chunkX).to(equal(-1))
        }

        it("calculates the chunk y position correctly") {
            expect(BlockPositionTests.position.chunkY).to(equal(2))
        }

        it("calculates the chunk z position correctly") {
            expect(BlockPositionTests.position.chunkZ).to(equal(11))
        }

        it("calculates the x in chunk position correctly") {
            expect(BlockPositionTests.position.xInChunk).to(equal(1))
        }

        it("calculates the y in chunk position correctly") {
            expect(BlockPositionTests.position.yInChunk).to(equal(10))
        }

        it("calculates the z in chunk position correctly") {
            expect(BlockPositionTests.position.zInChunk).to(equal(12))
        }
    }
}
