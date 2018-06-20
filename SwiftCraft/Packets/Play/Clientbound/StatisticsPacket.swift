//
//  StatisticsPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Send as response to to a statistics request.
public struct StatisticsPacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .play, id: 0x07)
    }

    public let statistics: [Statistic]

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
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

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        type = try String(from: buffer)
        value = try VarInt32(from: buffer).integer
    }
}
