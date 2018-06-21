//
//  Gamemode.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// The gamemode of a player.
public struct Gamemode: Hashable {
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
        guard let mode = Mode(rawValue: Int(id & 0x3f)) else {
            return nil
        }

        self.init(mode: mode, hardcore: id & 0x80 != 0)
    }
}
