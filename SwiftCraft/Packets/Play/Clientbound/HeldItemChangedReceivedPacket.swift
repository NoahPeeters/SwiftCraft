//
//  HeldItemChangedReceivedPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Packet informing the client that its selected slot has changed.
public struct HeldItemChangedReceivedPacket: DeserializablePacket, LoginPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x3A
    }

    /// The new selected slot id
    public let selectedSlot: Byte

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        selectedSlot = try Byte(from: buffer)
    }
}
