//
//  BlockChangePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 19.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Informs the client about a change of a block.
public struct BlockChangePacket: SimpleDeserializablePacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x0B)

    /// The location of the block.
    let location: Position

    /// The new block id.
    let blockID: BlockID

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        location = try Position(from: buffer)
        blockID = try BlockID(rawValue: UInt16(VarInt32(from: buffer).value))
    }
}
