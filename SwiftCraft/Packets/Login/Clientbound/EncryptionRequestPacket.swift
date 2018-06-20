//
//  EncryptionRequest.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Requests the start of encryption.
public struct EncryptionRequestPacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .login, id: 0x01)
    }

    /// The server id of the server.
    ///
    /// - Note: In the current implementation this is always empty and
    ///         is not used except for the response to this packet.
    public let serverID: String

    /// The public key of the server.
    ///
    /// - Note: This key must be used to encrypt the `verifyToken` and a shared secret.
    public let publicKey: ByteArray

    /// The verify token received from the server.
    public let verifyToken: ByteArray

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        serverID = try String(from: buffer)

        let publicKeyLength = try VarInt32(from: buffer)
        publicKey = try buffer.read(lenght: Int(publicKeyLength.value))

        let verifyTokenLength = try VarInt32(from: buffer)
        verifyToken = try buffer.read(lenght: Int(verifyTokenLength.value))
    }
}
