//
//  BlockID.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

// The id of a block
public struct BlockID: CustomStringConvertible, Hashable {
    /// The raw underlying id
    public let rawValue: UInt16

    /// The block id.
    public var id: UInt16 {
        return rawValue >> 4
    }

    /// Metadata.
    public var meta: UInt16 {
        return rawValue & 0x15
    }

    public var description: String {
        return "BlockID(id: \(id), meta: \(meta))"
    }
}
