//
//  ClientStatusPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Sends a status update to the server.
public struct ClientStatusPacket: BufferEncodablePacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x03)

    /// The action id of the packet. Send 0 to perform respawn and 1 for a statistics request.
    public let actionID: Int32

    public func encodeData<Buffer: WriteBuffer>(to buffer: Buffer) where Buffer.Element == Byte {
        VarInt32(actionID).encode(to: buffer)
    }
}

extension MinecraftClient {
    public func performRespawn() {
        sendPacket(ClientStatusPacket(actionID: 0))
    }

    public func requestStatistics() {
        sendPacket(ClientStatusPacket(actionID: 1))
    }
}
