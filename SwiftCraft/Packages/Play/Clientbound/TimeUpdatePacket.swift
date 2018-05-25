//
//  TimeUpdatePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

import Foundation

public struct TimeUpdatePacket: ReceivedPacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x47)

    public let worldAge: Int64
    public let timeOfDay: Int64

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        worldAge = try Int64(from: buffer)
        timeOfDay = try Int64(from: buffer)
    }
}
