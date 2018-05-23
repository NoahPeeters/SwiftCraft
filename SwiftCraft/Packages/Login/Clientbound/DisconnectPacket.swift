//
//  DisconnectPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

struct DisconnectPacket: HandleablePacket {
    static var packetID = PacketID(connectionState: .login, id: 0x00)

    let message: String

    init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        message = try String(from: buffer)
    }

    func handle(with client: MinecraftClient) {
        client.receivedDisconnectPacket(self)
    }
}

extension MinecraftClient {
    func receivedDisconnectPacket(_ packet: DisconnectPacket) {
        print("disconnect: \(packet.message)")
    }
}
