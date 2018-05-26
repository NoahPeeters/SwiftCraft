//
//  MultiBlockChangePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// A packet received if multiple blocks changed in the same chunk in the same tick.
public struct ReceiveMultiBlockChangePacket: ReceivedPacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x10)

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        let chunkX = try Int(Int32(from: buffer))
        let chunkZ = try Int(Int32(from: buffer))

        let blockChangeCount = try VarInt32(from: buffer)

        for _ in 0..<blockChangeCount.value {
            let horrizontalPosition = try Byte(from: buffer)
            let y = try Byte(from: buffer)
            let blockID = try VarInt32(from: buffer)

            let x = chunkX * 16 + Int((horrizontalPosition & 0xF0) >> 4)
            let z = chunkZ * 16 + Int((horrizontalPosition & 0x0F))

            print("(\(x)|\(y)|\(z): \(blockID)")
        }
    }
}
