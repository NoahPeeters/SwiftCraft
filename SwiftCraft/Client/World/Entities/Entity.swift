//
//  Entity.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// The ID of an entity.
public typealias EntityID = Int32

public class Entity: CustomStringConvertible {
    public var x: Double = 0
    public var y: Double = 0
    public var z: Double = 0

    public var yaw: Double = 0
    public var pitch: Double = 0

    public var description: String {
        return "Entity(x: \(x), y: \(y), z: \(z))"
    }

    public init() {

    }
}
