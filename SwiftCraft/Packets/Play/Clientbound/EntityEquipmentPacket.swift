//
//  EntityEquipmentPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 27.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Updates the equipment of an entity.
public struct EntityEquipmentPacket: SimpleDeserializablePacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x3F)

    /// The id of the entity.
    public let entityID: EntityID

    /// The affected slot.
    public let slot: Slot

    /// The content of the slot.
    public let slotContent: SlotContent

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        entityID = try VarInt32(from: buffer).value
        slot = try Slot(rawValue: Byte(VarInt32(from: buffer).value)).unwrap(EntityEquipmentPacketError.invalidSlotID)
        slotContent = try SlotContent(from: buffer)
    }

    public enum Slot: Byte {
        case hand = 0
        case offHand
        case armorBoots
        case armorLeggings
        case armorChestplate
        case armorHead
    }
}

/// Errors which can occure while decoding an `EntityEquipmentPacket`.
public enum EntityEquipmentPacketError: Error {
    /// The received slot id is invalid.
    case invalidSlotID
}
