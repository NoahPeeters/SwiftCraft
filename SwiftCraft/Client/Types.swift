//
//  Types.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// The ID of an entity
public typealias EntityID = Int32

/// The id of a recipe
public typealias RecipeID = Int

/// The gamemode of a player.
public struct Gamemode {
    /// The mode of the gamemode.
    public enum Mode: Int {
        /// Survival mode.
        case survival = 0

        /// Creative mode.
        case creative = 1

        /// Adventure mode.
        case adventure = 2

        /// Spectator mode.
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
public struct Dimension {
    /// The id of the dimension
    let id: Int32

    /// The nether.
    static let nether: Dimension = Dimension(id: -1)

    /// The overworld.
    static let overworld: Dimension = Dimension(id: 0)

    /// The end.
    static let end: Dimension = Dimension(id: 1)
}

/// Difficulty of the game.
public enum Difficulty: Byte {
    /// Peaceful
    case peaceful = 0

    /// Easy
    case easy = 1

    /// Normal
    case normal = 2

    // Hard
    case hard = 3
}

/// The level type of the current world.
public enum LevelType: String {
    /// The default level type.
    case `default`

    /// A flat world.
    case flat

    /// Large biomes.
    case largeBiomes

    /// Amplified.
    case amplified

    /// Something else.
    case defaultUnknown = "default_1_1"
}

/// The location of a received chat messeage.
public enum ChatMessageLocation: Byte {
    /// A normal chat message of another player.
    case chat = 0

    /// A chat message of the server.
    case systemMessage = 1

    /// A message which should be shown in the center of the screen.
    case gameInfo = 2
}
