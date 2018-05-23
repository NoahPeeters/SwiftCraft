//
//  JoinGamePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

struct JoinGamePacket: HandleablePacket {
    static var packetID = PacketID(connectionState: .play, id: 0x23)

    let playerEntityID: EntityID
    let gameMode: Gamemode
    let dimension: Dimension
    let difficulty: Difficulty
    let maxPlayers: Byte
    let levelType: LevelType
    let reducedDebugInfo: Bool

    init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        playerEntityID = try Int(Int32(from: buffer))
        gameMode = try Gamemode(id: Byte(from: buffer)).unwrap(JoinGamePacketError.unknownGamemode)
        dimension = try Dimension(rawValue: Int(Int32(from: buffer))).unwrap(JoinGamePacketError.unknownDimension)
        difficulty = try Difficulty(rawValue: Byte(from: buffer)).unwrap(JoinGamePacketError.unknownDifficulty)
        maxPlayers = try Byte(from: buffer)
        levelType = try LevelType(rawValue: String(from: buffer)).unwrap(JoinGamePacketError.unknownLevelType)
        reducedDebugInfo = try Bool(from: buffer)
    }

    func handle(with client: MinecraftClient) {
        client.receivedJoinGamePacket(self)
    }
}

extension MinecraftClient {
    func receivedJoinGamePacket(_ packet: JoinGamePacket) {
        print("receivedJoinGamePacket")
        print(packet)
    }
}

enum JoinGamePacketError: Error {
    case unknownGamemode
    case unknownDimension
    case unknownDifficulty
    case unknownLevelType
}
