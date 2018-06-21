//
//  WindowItemsPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 19.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Sent by the server when items in multiple slots (in a window) are added/removed.
public struct WindowItemsPacket: DeserializablePacket, LoginPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x14
    }

    /// The id of the inventory window. 0 For the players inventory.
    public let windowID: Int

    /// The content of the slots.
    public let slotContent: [SlotContent]

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        windowID = try Int(Byte(from: buffer))

        let slotCount = try Int(Int16(from: buffer))
        slotContent = try Array(from: buffer, count: slotCount)
    }
}
