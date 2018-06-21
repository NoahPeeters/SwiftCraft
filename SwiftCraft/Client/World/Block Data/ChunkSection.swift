//
//  ChunkSection.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 27.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// A chunk section as received in the `ChunkDataPacket`.
public class ChunkSection {
    private var blockData: BlockData
    private var blockLight: ByteArray
    private var skyLight: ByteArray?

    private static let lightArraySize = 16 * 16 * 16 / 2

    private enum BlockData {
        case compressed(bitsPerBlock: Int, palette: [UInt16], dataArray: [UInt64])
        case uncompressed(blockIDs: BlockIDsWrapper)
    }

    private class BlockIDsWrapper {
        internal var blockIDs: [BlockID]

        internal init(blockIDs: [BlockID]) {
            self.blockIDs = blockIDs
        }
    }

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, hasSkylight: Bool) throws {
        // load bits per block
        let rawBitsPerBlock = try Byte(from: buffer)
        let bitsPerBlock = Int(rawBitsPerBlock > 8 ? 13 : max(rawBitsPerBlock, 4))

        // read palette
        let palette = try [VarInt32](from: buffer).map { UInt16($0.value) }
        let dataArray = try [UInt64](from: buffer)

        blockData = .compressed(bitsPerBlock: bitsPerBlock, palette: palette, dataArray: dataArray)

        // Read lighting
        blockLight = try buffer.read(lenght: ChunkSection.lightArraySize)
        skyLight = try !hasSkylight ? nil : buffer.read(lenght: ChunkSection.lightArraySize)
    }

    public func blockIndex(x: Int, y: Int, z: Int) -> Int {
        return ((y * 16) + z) * 16 + x
    }

    public func blockIndex(block: BlockPosition) -> Int {
        return blockIndex(x: block.xInChunk, y: block.yInChunk, z: block.zInChunk)
    }

    public func getBlockLight(blockIndex: Int) -> Byte {
        let (lightIndex, byteOffset) = blockIndex.quotientAndRemainder(dividingBy: 2)

        if byteOffset == 0 {
            return blockLight[lightIndex] & 0x0F
        } else {
            return blockLight[lightIndex] >> 4
        }
    }

    public func setBlockLight(blockIndex: Int, newValue: Byte) {
        let (lightIndex, byteOffset) = blockIndex.quotientAndRemainder(dividingBy: 2)

        if byteOffset == 0 {
            blockLight[lightIndex] = blockLight[lightIndex] & 0xF0 | newValue
        } else {
            blockLight[lightIndex] = blockLight[lightIndex] & 0x0F | (newValue << 4)
        }
    }

    public func getSkyLight(blockIndex: Int) -> Byte? {
        let (lightIndex, byteOffset) = blockIndex.quotientAndRemainder(dividingBy: 2)

        guard let rawValue = skyLight?[lightIndex] else {
            return nil
        }

        if byteOffset == 0 {
            return rawValue & 0x0F
        } else {
            return rawValue >> 4
        }
    }

    public func setSkyLight(blockIndex: Int, newValue: Byte) {
        let (lightIndex, byteOffset) = blockIndex.quotientAndRemainder(dividingBy: 2)

        guard let rawValue = skyLight?[lightIndex] else {
            return
        }

        if byteOffset == 0 {
            skyLight?[lightIndex] = rawValue & 0xF0 | newValue
        } else {
            skyLight?[lightIndex] = rawValue & 0x0F | (newValue << 4)
        }
    }

    public func getBlockID(blockIndex: Int) -> BlockID {
        switch blockData {
        case let .uncompressed(blockIDs):
            return blockIDs.blockIDs[blockIndex]
        case let .compressed(bitsPerBlock, palette, dataArray):
            let blockIDs = decompress(bitsPerBlock: bitsPerBlock, palette: palette, dataArray: dataArray)
            self.blockData = .uncompressed(blockIDs: BlockIDsWrapper(blockIDs: blockIDs))
            return blockIDs[blockIndex]
        }
    }

    public func setBlockID(blockIndex: Int, newValue: BlockID) {
        switch blockData {
        case let .uncompressed(blockIDs):
            blockIDs.blockIDs[blockIndex] = newValue
        case let .compressed(bitsPerBlock, palette, dataArray):
            var blockIDs = decompress(bitsPerBlock: bitsPerBlock, palette: palette, dataArray: dataArray)
            blockIDs[blockIndex] = newValue
            self.blockData = .uncompressed(blockIDs: BlockIDsWrapper(blockIDs: blockIDs))
        }
    }

    private func decompress(bitsPerBlock: Int, palette: [UInt16], dataArray: [UInt64]) -> [BlockID] {
        let individualValueMask = UInt64((1 << bitsPerBlock) - 1)

        return (0..<16*16*16).map { blockIndex in
            let (startIndex, startOffset) = (blockIndex * bitsPerBlock).quotientAndRemainder(dividingBy: 64)
            let endIndex = ((blockIndex + 1) * bitsPerBlock - 1) / 64

            // Read data
            let data: UInt64
            if startIndex == endIndex {
                data = dataArray[startIndex] >> startOffset
            } else {
                data = dataArray[startIndex] >> startOffset | dataArray[endIndex] << (64 - startOffset)
            }

            if bitsPerBlock < 8 {
                return BlockID(rawValue: palette[Int(data & individualValueMask)])
            } else {
                return BlockID(rawValue: UInt16(data & individualValueMask))
            }
        }
    }
}
