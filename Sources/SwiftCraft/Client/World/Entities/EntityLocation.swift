//
//  EntityLocation.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// The location of an entity
public struct EntityLocation: Hashable, DeserializableDataType {
    /// The location in the x direction.
    public let x: Double

    /// The location in the y direction.
    public let y: Double

    /// The location in the z direction.
    public let z: Double

    /// Creates a new location from x, y, and z.
    ///
    /// - Parameters:
    ///   - x: The x component.
    ///   - y: The y component.
    ///   - z: The z component.
    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        x = try Double(from: buffer)
        y = try Double(from: buffer)
        z = try Double(from: buffer)
    }
}
