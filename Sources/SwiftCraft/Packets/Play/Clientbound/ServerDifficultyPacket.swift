//
//  ServerDifficultyPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// A packet indicating that the server difficulty changed.
public struct ServerDifficultyPacket: DeserializablePacket, PlayPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x0D
    }

    /// The difficulty of the world.
    public let difficulty: Difficulty

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        difficulty = try Difficulty(rawValue: Byte(from: buffer)).unwrap(ServerDifficultyPacketError.unknownDifficulty)
    }

    /// Errors which can occure while deserializing a `ServerDifficultyPacket`.
    public enum ServerDifficultyPacketError: Error {
        /// The difficultiy received is unknown.
        case unknownDifficulty
    }
}
