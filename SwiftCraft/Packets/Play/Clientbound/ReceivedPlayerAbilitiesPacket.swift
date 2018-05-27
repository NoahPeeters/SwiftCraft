//
//  ReceivedPlayerAbilitiesPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Informs the player about its abilities.
public struct ReceivedPlayerAbilitiesPacket: SimpleDeserializablePacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x2C)

    /// Flag of the invulnerability of the player.
    public let invulnerable: Bool

    /// Flag of the player flying status.
    public let flying: Bool

    /// Flag of the rules of flying.
    public let allowFlying: Bool

    /// Flag for creative mode instant break.
    public let instantBreak: Bool

    /// The maximum speed allowed for flying.
    public let flyingSpeed: Float

    /// A modifier applied to the field of view. This is used for example for speed potions.
    public let fieldOfViewModifier: Float

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        let flags = try Byte(from: buffer)

        invulnerable = flags & 0x01 != 0
        flying = flags & 0x02 != 0
        allowFlying = flags & 0x04 != 0
        instantBreak = flags & 0x08 != 0

        flyingSpeed = try Float(from: buffer)
        fieldOfViewModifier = try Float(from: buffer)

    }
}
