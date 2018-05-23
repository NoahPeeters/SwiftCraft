//
//  KeepaliveResponsePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

public struct KeepaliveResponsePacket: BufferEncodablePacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x0B)

    let id: Int64

    public func encodeData<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        id.encode(to: buffer)
    }
}

extension MinecraftClient {
    public func sendKeepaliveResponsePacket(id: Int64) {
        sendPacket(KeepaliveResponsePacket(id: id))
    }
}
