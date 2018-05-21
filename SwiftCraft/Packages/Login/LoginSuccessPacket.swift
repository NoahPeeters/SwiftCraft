//
//  LoginSuccessPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

struct LoginSuccessPacket: HandleablePacket {
    static var packetID = PacketID(connectionState: .login, id: 0x02)

    let uuid: String
    let username: String

    init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        uuid = try String(from: buffer)
        username = try String(from: buffer)
    }

    func handle(with client: MinecraftClient) {
        client.receivedLoginSuccessPacket(self)
    }
}

extension MinecraftClient {
    func receivedLoginSuccessPacket(_ packet: LoginSuccessPacket) {
        print("receivedLoginSuccessPacket")
        print(packet)
    }
}
