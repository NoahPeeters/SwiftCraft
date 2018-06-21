//
//  Dimension.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Types of dimensions in minecraft.
public struct Dimension: Hashable {
    /// The id of the dimension
    public let id: Int32

    /// Flag whether the dimension has skylight data.
    public var hasSkylight: Bool {
        return self == .overworld
    }

    /// The nether.
    public static let nether: Dimension = Dimension(id: -1)

    /// The overworld.
    public static let overworld: Dimension = Dimension(id: 0)

    /// The end.
    public static let end: Dimension = Dimension(id: 1)
}
