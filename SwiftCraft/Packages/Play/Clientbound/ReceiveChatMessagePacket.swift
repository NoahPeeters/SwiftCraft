//
//  ReceiveChatMessagePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

struct ReceiveChatMessagePacket: HandleablePacket {
    static var packetID = PacketID(connectionState: .play, id: 0x0F)

    let message: String
    let position: ChatMessageLocation

    init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        message = try String(from: buffer)
        position = try ChatMessageLocation(rawValue: Byte(from: buffer)).unwrap(ChatMessagePacketError.unknownPosition)
    }

    func handle(with client: MinecraftClient) {
        client.receivedChatMessagePacket(self)
    }
}

extension MinecraftClient {
    func receivedChatMessagePacket(_ packet: ReceiveChatMessagePacket) {
        print("chat: \(packet.message)")
    }
}

enum ChatMessagePacketError: Error {
    case unknownPosition
}
