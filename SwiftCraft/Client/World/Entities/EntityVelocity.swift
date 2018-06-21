//
//  EntityVelocity.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// The velocity of an entity
public struct EntityVelocity: Hashable, DeserializableDataType {
    /// The velocity in the x direction.
    public let x: Int16

    /// The velocity in the y direction.
    public let y: Int16

    /// The velocity in the z direction.
    public let z: Int16

    /// Creates a new velocity from x, y, and z.
    ///
    /// - Parameters:
    ///   - x: The x component.
    ///   - y: The y component.
    ///   - z: The z component.
    public init(x: Int16, y: Int16, z: Int16) {
        self.x = x
        self.y = y
        self.z = z
    }

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        x = try Int16(from: buffer)
        y = try Int16(from: buffer)
        z = try Int16(from: buffer)
    }
}
