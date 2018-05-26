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

    /// Errors which can occure while decoding a `JoinGamePacket`.
    ///
    /// - unknownGamemode: The gamemode received is unknown.
    /// - unknownDimension: The dimension recieved is unknown.
    /// - unknownDifficulty: The difficultiy received is unknown.
    /// - unknownLevelType: The level type received is unknown.
    public enum ServerDifficultyPacketError: Error {
        case unknownDifficulty
    }
}
