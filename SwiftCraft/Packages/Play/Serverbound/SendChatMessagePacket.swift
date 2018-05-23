//
//  SendChatMessagePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

public struct SendChatMessagePacket: BufferEncodablePacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x02)

    let message: String

    public func encodeData<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        message.encode(to: buffer)
    }
}

extension MinecraftClient {
    public func sendMessage(_ message: String) {
        sendPacket(SendChatMessagePacket(message: message))
    }
}
