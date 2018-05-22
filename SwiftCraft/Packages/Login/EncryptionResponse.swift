//
//  EncryptionResponse.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 22.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

struct EncryptionResponsePacket: BufferEncodablePacket {
    static var packetID = PacketID(connectionState: .login, id: 0x01)

    let encryptedSharedSecret: ByteArray
    let encryptedVerifyToken: ByteArray

    public func encodeData<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        VarInt32(encryptedSharedSecret.count).encode(to: buffer)
        buffer.write(elements: encryptedSharedSecret)

        VarInt32(encryptedVerifyToken.count).encode(to: buffer)
        buffer.write(elements: encryptedVerifyToken)
    }
}
