//
//  PacketLibrary.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// A packet which can be handled by a `MinecraftClient`
public protocol ReceivedPacket: DecodablePacket {}

/// A library of packets.
public protocol PacketLibrary {
    /// Searches the correct packet and tries to decode and handle it.
    ///
    /// - Parameters:
    ///   - buffer: The buffer to decode the packet from.
    ///   - packetID: The packet if of the packet in the buffer.
    ///   - client: The client to handle the packet.
    /// - Throws: An error which might occure.
    func parse<Buffer: ReadBuffer>(
        _ buffer: Buffer, packetID: PacketID) throws -> ReceivedPacket where Buffer.Element == Byte
}

/// Errors which might occure while handling a packet.
///
/// - unknowPacketID: The library does not know a packet with the given packet id.
public enum PacketLibraryError: Error {
    case unknowPacketID(packetID: PacketID)
}

/// The default packet library which includes all packets currently implemented
public struct DefaultPacketLibrary: PacketLibrary {
    /// List of packet types.
    let packets: [ReceivedPacket.Type] = [
        // Login
        DisconnectPacket.self,
        EncryptionRequestPacket.self,
        LoginSuccessPacket.self,
        SetCompressionPacket.self,

        // Play
        ReceiveChatMessagePacket.self,
        ReceiveMultiBlockChangePacket.self,
        KeepaliveRequestPacket.self,
        JoinGamePacket.self,
        TimeUpdatePacket.self
    ]

    /// Creates a new packet library.
    public init() {}

    public func parse<Buffer: ReadBuffer>(
        _ buffer: Buffer, packetID: PacketID) throws -> ReceivedPacket where Buffer.Element == Byte {
        guard let packetType = packets.first(where: { $0.packetID == packetID }) else {
            throw PacketLibraryError.unknowPacketID(packetID: packetID)
        }

        return try packetType.init(from: buffer)
    }
}
