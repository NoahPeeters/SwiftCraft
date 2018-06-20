//
//  ProtocolVersion.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

extension MinecraftClient {
    /// Relation of all supported human readable versions and protocol version numbers.
    public static let supportedProtocolVersions = [
        "17w43b": 342,
        "17w43a": 341,
        "1.12.2": 340
    ]

    /// The most recent released protocol version number.
    public static var mostRecentSupportedProtocolVersion: Int {
        return supportedProtocolVersions.values.max()!
    }
}
