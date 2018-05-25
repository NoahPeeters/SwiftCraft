//
//  SetCompressionPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 22.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

public struct SetCompressionPacket: ReceivedPacket {
    public static var packetID = PacketID(connectionState: .login, id: 0x03)

    public let threshold: Int

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        threshold = try Int(VarInt32(from: buffer).value)
    }
}
