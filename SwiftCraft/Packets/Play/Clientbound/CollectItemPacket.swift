//
//  CollectItemPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Sent by the server when someone picks up an item lying on the ground.
///
/// - Attention: The entity is destroyed in a seperated packet.
public struct CollectItemPacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .play, id: 0x4B)
    }

    /// The id of the item.
    let collectedEntityID: EntityID

    /// The id of the entity which collected the items.
    let collectorEntityID: EntityID

    /// The number of items collected.
    let itemCount: Int

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        collectedEntityID = try VarInt32(from: buffer).value
        collectorEntityID = try VarInt32(from: buffer).value
        itemCount = try VarInt32(from: buffer).integer
        print(self)
    }
}
