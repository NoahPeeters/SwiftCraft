//
//  KeepaliveRequestPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

struct KeepaliveRequestPacket: HandleablePacket {
    static var packetID = PacketID(connectionState: .play, id: 0x1F)

    let id: Int64

    init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        id = try Int64(from: buffer)
    }

    func handle(with client: MinecraftClient) {
        client.receivedKeepaliveRequestPacket(self)
    }
}

extension MinecraftClient {
    func receivedKeepaliveRequestPacket(_ packet: KeepaliveRequestPacket) {
        print("keepalive \(packet.id)")
        sendKeepaliveResponsePacket(id: packet.id)
    }
}
