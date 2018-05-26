//
//  Types.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// THe ID of an entity
public typealias EntityID = Int

/// The gamemode of a player.
public struct Gamemode {
    /// The mode of the gamemode.
    ///
    /// - survival: Survival mode.
    /// - creative: Creative mode.
    /// - adventure: Adventure mode.
    /// - spectator: Spectator mode.
    public enum Mode: Int {
        case survival = 0
        case creative = 1
        case adventure = 2
        case spectator = 3
    }

    /// The actual gamemode.
    public let mode: Mode

    /// The hardcore flag.
    public let hardcore: Bool

    /// Creates a new gamemode.
    ///
    /// - Parameters:
    ///   - mode: The mode.
    ///   - hardcore: Hardcore flag.
    public init(mode: Mode, hardcore: Bool) {
        self.mode = mode
        self.hardcore = hardcore
    }

    /// Creates a new gamemode from the id send by the server.
    ///
    /// - Parameter id: The id send by the server.
    internal init?(id: Byte) {
        guard let mode = Mode(rawValue: Int(id & 0x3f)) else { return nil }
        self.init(mode: mode, hardcore: id & 0x80 != 0)
    }
}

/// Types of dimensions in minecraft.
///
/// - nether: The nether.
/// - overworld: The overworld.
/// - end: The end.
public enum Dimension: Int {
    case nether = -1
    case overworld = 0
    case end = 1
}

/// Difficulty of the game.
///
/// - peaceful: Peaceful
/// - easy: Easy
/// - normal: Normal
/// - hard: Hard
public enum Difficulty: Byte {
    case peaceful = 0
    case easy = 1
    case normal = 2
    case hard = 3
}

/// The level type of the current world.
///
/// - `default`: The default level type.
/// - flat: A flat world.
/// - largeBiomes: Large biomes.
/// - amplified: Amplified.
/// - defaultUnknown: Something else.
public enum LevelType: String {
    case `default`
    case flat
    case largeBiomes
    case amplified
    case defaultUnknown = "default_1_1"
}

/// The location of a received chat messeage.
///
/// - chat: A normal chat message of another player.
/// - systemMessage: A chat message of the server.
/// - gameInfo: A message which should be shown in the center of the screen.
public enum ChatMessageLocation: Byte {
    case chat = 0
    case systemMessage = 1
    case gameInfo = 2
}
