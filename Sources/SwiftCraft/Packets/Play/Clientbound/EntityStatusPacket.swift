//
//  EntityStatusPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Packet send once per second with the current time.
public struct EntityStatusPacket: DeserializablePacket, PlayPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x1B
    }

    /// The id of the affected entity
    public let entityID: EntityID

    /// The received status of the entity
    public let entityStatus: Byte

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        entityID = try EntityID(from: buffer)
        entityStatus = try Byte(from: buffer)
    }
}
