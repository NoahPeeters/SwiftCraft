//
//  LoginStartPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

public struct LoginStartPacket: BufferEncodablePacket {
    public static var packetID = PacketID(connectionState: .login, id: 0x00)

    let username: String

    public func encodeData<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        username.encode(to: buffer)
    }
}

extension MinecraftClient {
    public func sendLoginStart(username: String) {
        sendPacket(LoginStartPacket(username: username))
    }
}
