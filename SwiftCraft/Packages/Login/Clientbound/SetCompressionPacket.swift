//
//  SetCompressionPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 22.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

struct SetCompressionPacket: HandleablePacket {
    static var packetID = PacketID(connectionState: .login, id: 0x03)

    let threshold: Int

    init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        threshold = try Int(VarInt32(from: buffer).value)
    }

    func handle(with client: MinecraftClient) {
        client.receivedSetCompressionPacket(self)
    }
}

extension MinecraftClient {
    func receivedSetCompressionPacket(_ packet: SetCompressionPacket) {
        if packet.threshold == -1 {
            disableCompression()
        } else {
            enableCompression(threshold: packet.threshold)
        }
    }
}
