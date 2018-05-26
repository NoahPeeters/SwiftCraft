//
//  HeldItemChangedReceivedPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Packet informing the client that its selected slot has changed.
public struct HeldItemChangedReceivedPacket: ReceivedPacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x3A)

    /// The new selected slot id
    public let selectedSlot: Byte

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        selectedSlot = try Byte(from: buffer)
    }
}
