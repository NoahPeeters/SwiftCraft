//
//  LoginSuccessPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Received from the server when the login was successful.
public struct LoginSuccessPacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .login, id: 0x02)
    }

    /// The uuid of the user.
    public let uuid: UUID

    /// The username of the user.
    public let username: String

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        uuid = try UUID(uuidString: String(from: buffer)).unwrap(LoginSuccessPacketError.invalidUUID)
        username = try String(from: buffer)
    }
}

/// Errors which might occure while decoding login success packets
enum LoginSuccessPacketError: Error {
    /// The uuid received is not valid.
    case invalidUUID
}
