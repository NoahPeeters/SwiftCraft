//
//  EntityHeadLookPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 19.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Updates the head look direction of an entity.
public struct EntityHeadLookPacket: SimpleDeserializablePacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x36)

    /// The id of the entity.
    public let entityID: EntityID

    /// The new angle.
    public let yaw: Angle

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        entityID = try VarInt32(from: buffer).value
        yaw = try Angle(from: buffer)
    }
}
