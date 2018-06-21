//
//  LevelType.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// The level type of the current world.
public enum LevelType: String, Hashable {
    /// The default level type.
    case `default` = "default"

    /// A flat world.
    case flat = "flat"

    /// Large biomes.
    case largeBiomes = "largeBiomes"

    /// Amplified.
    case amplified = "amplified"

    /// Something else.
    case defaultUnknown = "default_1_1"
}
