//
//  JoinGamePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// A packet received from the server after a successfull switch of the connection state from login to play.
public struct JoinGamePacket: ReceivedPacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x23)

    /// The id of the player.
    public let playerEntityID: EntityID

    /// The gememode of the player.
    public let gameMode: Gamemode

    /// The dimension in wich the player is.
    public let dimension: Dimension

    /// The difficulty of the world.
    public let difficulty: Difficulty

    /// The maximum number of players on the server. This option is most of the time ignored.
    public let maxPlayers: Byte

    /// The type of the world.
    public let levelType: LevelType

    /// Debug option.
    public let reducedDebugInfo: Bool

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        playerEntityID = try EntityID(from: buffer)
        gameMode = try Gamemode(id: Byte(from: buffer)).unwrap(JoinGamePacketError.unknownGamemode)
        dimension = try Dimension(rawValue: Int(Int32(from: buffer))).unwrap(JoinGamePacketError.unknownDimension)
        difficulty = try Difficulty(rawValue: Byte(from: buffer)).unwrap(JoinGamePacketError.unknownDifficulty)
        maxPlayers = try Byte(from: buffer)
        levelType = try LevelType(rawValue: String(from: buffer)).unwrap(JoinGamePacketError.unknownLevelType)
        reducedDebugInfo = try Bool(from: buffer)
    }

    /// Errors which can occure while decoding a `JoinGamePacket`.
    ///
    /// - unknownGamemode: The gamemode received is unknown.
    /// - unknownDimension: The dimension recieved is unknown.
    /// - unknownDifficulty: The difficultiy received is unknown.
    /// - unknownLevelType: The level type received is unknown.
    public enum JoinGamePacketError: Error {
        case unknownGamemode
        case unknownDimension
        case unknownDifficulty
        case unknownLevelType
    }
}
