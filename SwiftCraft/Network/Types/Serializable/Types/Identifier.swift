//
//  Identifier.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// An identifier of the form namespace:identifier
public struct Identifier: Serializable, Hashable {
    /// The raw identifier.
    public let rawIdentifier: String

    /// The parts of the identifier.
    public var identifierParts: [String] {
        return rawIdentifier.components(separatedBy: ":")
    }

    /// The namespace of the identifier.
    public var namespace: String {
        return identifierParts.count > 1 ? identifierParts[0] : "minecraft"
    }

    /// The symbol of the identifier.
    public var symbol: String {
        return identifierParts.count > 1 ? identifierParts[1] : identifierParts[0]
    }

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        rawIdentifier = try String(from: buffer)
    }

    public func serialize<Buffer: ByteWriteBuffer>(to buffer: Buffer) {
        rawIdentifier.serialize(to: buffer)
    }
}
