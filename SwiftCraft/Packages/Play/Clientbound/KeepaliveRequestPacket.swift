//
//  KeepaliveRequestPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

public struct KeepaliveRequestPacket: ReceivedPacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x1F)

    public let id: Int64

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        id = try Int64(from: buffer)
    }
}
