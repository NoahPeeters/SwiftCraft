//
//  EncryptionResponse.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 22.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Response to the `EncryptionRequestPacket`. This packet is essential for the login.
struct EncryptionResponsePacket: BufferSerializablePacket {
    static var packetID = PacketID(connectionState: .login, id: 0x01)

    /// The encrypted shared secret.
    /// The shared secret will be used by both the server and the client to encrypt all upcomming packets.
    let encryptedSharedSecret: ByteArray

    /// The encrypted verify token from the encryption request.
    let encryptedVerifyToken: ByteArray

    public func serializeData<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        VarInt32(encryptedSharedSecret.count).serialize(to: buffer)
        buffer.write(elements: encryptedSharedSecret)

        VarInt32(encryptedVerifyToken.count).serialize(to: buffer)
        buffer.write(elements: encryptedVerifyToken)
    }
}
