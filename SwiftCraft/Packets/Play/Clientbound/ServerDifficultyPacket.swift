//
//  ServerDifficultyPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// A packet indicating that the server difficulty changed.
public struct ServerDifficultyPacket: ReceivedPacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x0D)

    /// The difficulty of the world.
    public let difficulty: Difficulty

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        difficulty = try Difficulty(rawValue: Byte(from: buffer)).unwrap(ServerDifficultyPacketError.unknownDifficulty)
    }

    /// Errors which can occure while decoding a `ServerDifficultyPacket`.
    public enum ServerDifficultyPacketError: Error {
        /// The difficultiy received is unknown.
        case unknownDifficulty
    }
}
