//
//  UpdateHealthPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 27.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Updates the players health status
public struct UpdateHealthPacket: SimpleDeserializablePacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x41)

    /// The current health status. 0 or less is dead. Max is 20.
    let health: Float

    /// The food level. Max is 20.
    let food: Int

    /// The food saturation. 0.0 - 5.0.
    let foodSaturation: Float

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        health = try Float(from: buffer)
        food = try VarInt32(from: buffer).integer
        foodSaturation = try Float(from: buffer)
    }
}
