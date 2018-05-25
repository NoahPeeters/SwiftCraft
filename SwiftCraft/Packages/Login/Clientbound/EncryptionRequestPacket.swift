//
//  EncryptionRequest.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

public struct EncryptionRequestPacket: ReceivedPacket {
    public static var packetID = PacketID(connectionState: .login, id: 0x01)

    public let serverID: String
    public let publicKey: ByteArray
    public let verifyToken: ByteArray

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        serverID = try String(from: buffer)

        let publicKeyLength = try VarInt32(from: buffer)
        publicKey = try buffer.read(lenght: Int(publicKeyLength.value))

        let verifyTokenLength = try VarInt32(from: buffer)
        verifyToken = try buffer.read(lenght: Int(verifyTokenLength.value))
    }
}
