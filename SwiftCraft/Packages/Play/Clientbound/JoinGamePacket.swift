//
//  JoinGamePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

public struct JoinGamePacket: ReceivedPacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x23)

    public let playerEntityID: EntityID
    public let gameMode: Gamemode
    public let dimension: Dimension
    public let difficulty: Difficulty
    public let maxPlayers: Byte
    public let levelType: LevelType
    public let reducedDebugInfo: Bool

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        playerEntityID = try Int(Int32(from: buffer))
        gameMode = try Gamemode(id: Byte(from: buffer)).unwrap(JoinGamePacketError.unknownGamemode)
        dimension = try Dimension(rawValue: Int(Int32(from: buffer))).unwrap(JoinGamePacketError.unknownDimension)
        difficulty = try Difficulty(rawValue: Byte(from: buffer)).unwrap(JoinGamePacketError.unknownDifficulty)
        maxPlayers = try Byte(from: buffer)
        levelType = try LevelType(rawValue: String(from: buffer)).unwrap(JoinGamePacketError.unknownLevelType)
        reducedDebugInfo = try Bool(from: buffer)
    }
}

public enum JoinGamePacketError: Error {
    case unknownGamemode
    case unknownDimension
    case unknownDifficulty
    case unknownLevelType
}
