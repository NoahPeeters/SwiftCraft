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

/// Errors which might occure while handling a packet.
///
/// - unknowPacketID: The library does not know a packet with the given packet id.
public enum PacketLibraryError: Error {
    case unknowPacketID(packetID: PacketID)
}

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
        ReceiveMultiBlockChangePacket.self,
        KeepaliveRequestPacket.self,
        JoinGamePacket.self,
        TimeUpdatePacket.self
    ]

    /// Creates a new packet library.
    public init() {}

    /// Parses a buffer and returns the packet.
    ///
    /// - Parameters:
    ///   - buffer: The buffer with the raw packet data. This buffer must not contain the packet id.
    ///   - packetID: The packet id of the packet in  the buffer.
    /// - Returns: The parsed packet.
    /// - Throws: An `PacketLibraryError.unknowPacketID` error if the packet is unknown.
    ///           If the packet decoding throws an error the error is forwared.
    public func parse<Buffer: ReadBuffer>(
        _ buffer: Buffer, packetID: PacketID) throws -> ReceivedPacket where Buffer.Element == Byte {
        guard let packetType = packets.first(where: { $0.packetID == packetID }) else {
            throw PacketLibraryError.unknowPacketID(packetID: packetID)
        }

        return try packetType.init(from: buffer)
    }
}
