//
//  Slot.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Describes the content of a slot.
public enum SlotContent: Hashable, DeserializableDataType {
    /// The slot is empty.
    case empty

    /// The slot contains the given data.
    case hasContent(blockID: BlockID, count: Byte, damage: Int16, nbt: NBT)

    /// The amount of items in the slot.
    public var count: Byte {
        switch self {
        case .empty:
            return 0
        case let .hasContent(_, count, _, _):
            return count
        }
    }

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        let blockID = try Int16(from: buffer)

        guard blockID >= 0 else {
            self = .empty
            return
        }

        let count = try Byte(from: buffer)
        let damage = try Int16(from: buffer)
        let nbt = try NBT(from: buffer)

        self = .hasContent(blockID: BlockID(rawValue: UInt16(blockID)), count: count, damage: damage, nbt: nbt)
    }
}
