//
//  SetSlotPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 19.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Updates the content of a slot
public struct SetSlotPacket: SimpleDeserializablePacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x16)

    /// The id of the inventory window. 0 For the players inventory.
    public let windowID: Int

    /// The slot that should be updated.
    public let slot: Int

    /// The content of the slot.
    public let slotContent: SlotContent

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        windowID = try Int(Byte(from: buffer))
        slot = try Int(Int16(from: buffer))
        slotContent = try SlotContent(from: buffer)
    }
}
