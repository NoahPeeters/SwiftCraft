//
//  HandshakePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

public struct HandshakePacket: BufferEncodablePacket {
    public static var packetID = PacketID(connectionState: .handshaking, id: 0x00)

    public let protocolVersion: Int
    public let serverAddress: String
    public let serverPort: UInt16
    public let nextState: ConnectionState

    public func encodeData<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        VarInt32(protocolVersion).encode(to: buffer)
        serverAddress.encode(to: buffer)
        serverPort.encode(to: buffer)
        VarInt32(nextState.rawValue).encode(to: buffer)
    }
}

extension MinecraftClient {
    public func sendHandshake(nextState: ConnectionState) {
        let packet = HandshakePacket(
            protocolVersion: 340,
            serverAddress: host as String,
            serverPort: UInt16(port),
            nextState: nextState)

        sendPacket(packet)
    }
}
