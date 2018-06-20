//
//  EntityStatusPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Packet send once per second with the current time.
public struct EntityStatusPacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .play, id: 0x1B)
    }

    /// The id of the affected entity
    let entityID: EntityID

    /// The received status of the entity
    let entityStatus: Byte

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        entityID = try EntityID(from: buffer)
        entityStatus = try Byte(from: buffer)
    }
}
