//
//  ReceiveChatMessagePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

public struct ReceiveChatMessagePacket: ReceivedPacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x0F)

    public let message: String
    public let position: ChatMessageLocation

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        message = try String(from: buffer)
        position = try ChatMessageLocation(rawValue: Byte(from: buffer)).unwrap(ChatMessagePacketError.unknownPosition)
    }
}

enum ChatMessagePacketError: Error {
    case unknownPosition
}
