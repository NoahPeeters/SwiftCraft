//
//  PacketLibrary.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

public protocol HandleablePacket: DecodablePacket {
    func handle(with client: MinecraftClient)
}

public protocol PacketLibrary {
    func parseAndHandle<Buffer: ReadBuffer>(
        _ buffer: Buffer, packetID: PacketID, with client: MinecraftClient) throws where Buffer.Element == Byte
}

public enum PacketLibraryError: Error {
    case unknowPacketID(packetID: PacketID)
}

public struct DefaultPacketLibrary: PacketLibrary {
    let packets: [HandleablePacket.Type] = [
        DisconnectPacket.self,
        EncryptionRequestPacket.self,
        LoginSuccessPacket.self
    ]

    public init() {}

    public func parseAndHandle<Buffer: ReadBuffer>(
        _ buffer: Buffer, packetID: PacketID, with client: MinecraftClient) throws where Buffer.Element == Byte {
        guard let packetType = packets.first(where: { $0.packetID == packetID }) else {
            throw PacketLibraryError.unknowPacketID(packetID: packetID)
        }

        let packet = try packetType.init(from: buffer)
        packet.handle(with: client)
    }
}
