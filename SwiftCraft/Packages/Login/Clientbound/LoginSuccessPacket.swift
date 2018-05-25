//
//  LoginSuccessPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

public struct LoginSuccessPacket: ReceivedPacket {
    public static var packetID = PacketID(connectionState: .login, id: 0x02)

    public let uuid: String
    public let username: String

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        uuid = try String(from: buffer)
        username = try String(from: buffer)
    }
}
