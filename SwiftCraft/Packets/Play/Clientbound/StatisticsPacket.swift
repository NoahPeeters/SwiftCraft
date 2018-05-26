//
//  StatisticsPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Send as response to to a statistics request.
public struct StatisticsPacket: ReceivedPacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x07)

    public let statistics: [Statistic]

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        statistics = try [Statistic](from: buffer)
    }
}

/// A statistics object.
public struct Statistic: DeserializableDataType {
    /// The identifier of the statistic value..
    /// A list can be found [here](https://gist.github.com/Alvin-LB/8d0d13db00b3c00fd0e822a562025eff).
    public let type: String

    /// The value of the statstic.
    public let value: Int

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        type = try String(from: buffer)
        value = try Int(VarInt32(from: buffer).value)
    }
}
