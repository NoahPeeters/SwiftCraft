//
//  EncryptionRequest.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

struct EncryptionRequestPacket: HandleablePacket {
    static var packetID = PacketID(connectionState: .login, id: 0x01)

    let serverID: String
    let publicKey: ByteArray
    let verifyToken: ByteArray

    init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        serverID = try String(from: buffer)

        let publicKeyLength = try VarInt32(from: buffer)
        publicKey = try buffer.read(lenght: Int(publicKeyLength.value))

        let verifyTokenLength = try VarInt32(from: buffer)
        verifyToken = try buffer.read(lenght: Int(verifyTokenLength.value))
    }

    func handle(with client: MinecraftClient) {
        client.receivedEncryptionRequestPacket(self)
    }
}

extension MinecraftClient {
    func receivedEncryptionRequestPacket(_ packet: EncryptionRequestPacket) {
        print("receivedEncryptionRequestPacket")
        print(packet)
    }
}
