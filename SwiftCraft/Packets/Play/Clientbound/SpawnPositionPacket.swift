//
//  SpawnPositionPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 19.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Sends the spawn location to the client.
public struct SpawnPositionPacket: SimpleDeserializablePacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x46)

    /// The spawn location. The compass will point to this location
    public let location: Position

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        location = try Position(from: buffer)
    }
}
