//
//  EntityStatusPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Packet send once per second with the current time.
public struct EntityStatusPacket: ReceivedPacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x1B)

    /// The id of the affected entity
    let entityID: EntityID

    /// The received status of the entity
    let entityStatus: Byte

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        entityID = try EntityID(from: buffer)
        entityStatus = try Byte(from: buffer)
    }
}
