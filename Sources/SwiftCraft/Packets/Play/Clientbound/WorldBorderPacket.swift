//
//  WorldBorderPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Updates the world border.
public struct WorldBorderPacket: DeserializablePacket, PlayPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x38
    }

    public let action: Action

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        let actionID = try VarInt32(from: buffer).integer

        switch actionID {
        case 0:
            action = try .setSize(diameter: Double(from: buffer))
        case 1:
            action = try .lerpSize(
                oldDiameter: Double(from: buffer),
                newDiameter: Double(from: buffer),
                speed: VarInt64(from: buffer).integer)
        case 2:
            action = try .setCenter(x: Double(from: buffer), z: Double(from: buffer))
        case 3:
            action = try .initialize(payload: Action.InitActionPayload(
                x: Double(from: buffer),
                z: Double(from: buffer),
                oldDiameter: Double(from: buffer),
                newDiameter: Double(from: buffer),
                speed: VarInt64(from: buffer).integer,
                portalTeleportBoundary: VarInt32(from: buffer).integer,
                warningTimeSeconds: VarInt32(from: buffer).integer,
                warningBlocks: VarInt32(from: buffer).integer))
        case 4:
            action = try .setWarningTime(seconds: VarInt32(from: buffer).integer)
        case 5:
            action = try .setWarningBlocks(blocks: VarInt32(from: buffer).integer)
        default:
            throw WorldBorderPacketError.invalidAction(actionID)
        }
    }

    public enum Action {
        case setSize(diameter: Double)
        case lerpSize(oldDiameter: Double, newDiameter: Double, speed: Int)
        case setCenter(x: Double, z: Double)
        case initialize(payload: InitActionPayload)
        case setWarningTime(seconds: Int)
        case setWarningBlocks(blocks: Int)

        public struct InitActionPayload {
            public let x: Double
            public let z: Double
            public let oldDiameter: Double
            public let newDiameter: Double
            public let speed: Int
            public let portalTeleportBoundary: Int
            public let warningTimeSeconds: Int
            public let warningBlocks: Int
        }
    }
}

public enum WorldBorderPacketError: Error {
    case invalidAction(Int)
}
