//
//  LoginStartPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Requests the initiation of the login request.
public struct LoginStartPacket: BufferSerializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .login, id: 0x00)
    }

    /// The username of the user which connects.
    ///
    /// - Attention: This username will be verified with the mojang server while logging in.
    let username: String

    public func serializeData<Buffer: ByteWriteBuffer>(to buffer: Buffer, context: SerializationContext) {
        username.serialize(to: buffer)
    }
}

extension MinecraftClient {
    /// Sends a login start packet to the server.
    ///
    /// - Parameter username: The username which will be used to authenticate.
    public func sendLoginStart(username: String) {
        sendPacket(LoginStartPacket(username: username))
    }
}
