//
//  HandshakePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// A packet to send to the server after connecting to start the communitation.
public struct HandshakePacket: BufferSerializablePacket {
    public static var packetID = PacketID(connectionState: .handshaking, id: 0x00)

    /// The version of the protocol which is used.
    public let protocolVersion: Int

    /// The address which was used to connect to the server. Currently unused by most servers.
    public let serverAddress: String

    /// The port which was used to connect to the server. Currently unused by most servers.
    public let serverPort: UInt16

    /// The state of the connection to switch to. This can be login or status.
    public let nextState: ConnectionState

    public func serializeData<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        VarInt32(protocolVersion).serialize(to: buffer)
        serverAddress.serialize(to: buffer)
        serverPort.serialize(to: buffer)
        VarInt32(nextState.rawValue).serialize(to: buffer)
    }
}

extension MinecraftClient {
    /// Sends a handshake packet to the server.
    ///
    /// - Parameter nextState: The state of the connection to switch to. This can be login or status.
    public func sendHandshake(nextState: ConnectionState) {
        let packet = HandshakePacket(
            protocolVersion: 340,
            serverAddress: host as String,
            serverPort: UInt16(port),
            nextState: nextState)

        sendPacket(packet)
    }
}
