//
//  TimeUpdatePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Packet send once per second with the current time.
public struct TimeUpdatePacket: SimpleDeserializablePacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x47)

    /// The ticks since the world first started.
    public let worldAge: Int64

    /// The time of the current day. Can be influenced by the /time command (for example /time set 0).
    public let timeOfDay: Int64

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        worldAge = try Int64(from: buffer)
        timeOfDay = try Int64(from: buffer)
    }
}
