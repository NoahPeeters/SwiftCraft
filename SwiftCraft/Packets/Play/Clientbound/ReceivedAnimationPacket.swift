//
//  ReceivedAnimationPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Tells the client to play an animation.
public struct ReceivedAnimationPacket: DeserializablePacket, LoginPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x06
    }

    /// The id of the entity to play the animation
    public let entityID: EntityID

    /// The animation to play
    public let animation: Animation

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        entityID = try VarInt32(from: buffer).value

        let animationID = try Byte(from: buffer)
        animation = try Animation(rawValue: animationID)
            .unwrap(ReceivedAnimationPacketError.invalidAnimation(animationID))
    }

    public enum Animation: Byte {
        case swingMainArm = 0
        case takeDamage = 1
        case leaveBad = 2
        case swingOffhand = 3
        case criticalEffect = 4
        case magicCriticalEffect = 5
    }
}

public enum ReceivedAnimationPacketError: Error {
    case invalidAnimation(Byte)
}
