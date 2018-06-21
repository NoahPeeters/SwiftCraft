//
//  AttachEntityPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 27.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Attaches an entity to another one.
public struct AttachEntityPacket: DeserializablePacket, PlayPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x3D
    }

    /// The id of the attached entity.
    public let attachedEntityID: EntityID

    /// The id of the holding entity.
    public let holdingEntityID: EntityID

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        attachedEntityID = try Int32(from: buffer)
        holdingEntityID = try Int32(from: buffer)
    }
}
