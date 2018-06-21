//
//  Difficulty.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Difficulty of the game.
public enum Difficulty: Byte, Hashable {
    /// Peaceful
    case peaceful = 0

    /// Easy
    case easy = 1

    /// Normal
    case normal = 2

    // Hard
    case hard = 3
}
