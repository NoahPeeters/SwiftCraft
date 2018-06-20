//
//  SpawnPaintingPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Tells the client to spawn a painting.
public struct SpawnPaintingPacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .play, id: 0x04)
    }

    /// The id of the painting.
    public let entityID: EntityID

    /// The uuid of the painting.
    public let entityUUID: UUID

    /// The title of the painting.
    public let title: String

    /// The location of the painting.
    public let location: Position

    /// The direction of the painting.
    public let direction: Direction

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        entityID = try VarInt32(from: buffer).value
        entityUUID = try UUID(from: buffer)
        title = try String(from: buffer)
        location = try Position(from: buffer)

        let directionID = try Byte(from: buffer)
        direction = try Direction(rawValue: directionID).unwrap(SpawnPaintingPacketError.invalidDirection(directionID))
    }

    public enum Direction: Byte {
        case south = 0
        case west = 1
        case north = 2
        case east = 3
    }
}

public enum SpawnPaintingPacketError: Error {
    case invalidDirection(Byte)
}
