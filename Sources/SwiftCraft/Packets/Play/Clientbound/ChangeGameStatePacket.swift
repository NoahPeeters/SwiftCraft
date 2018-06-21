//
//  ChangeGameStatePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Changes the game state.
public struct ChangeGameStatePacket: DeserializablePacket, PlayPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x1E
    }

    /// The action to perform.
    public let action: Action

    /// Additional value
    public let value: Float

    public enum Action: Byte {
        case invalidBed = 0
        case beginRaining = 1
        case endRaining = 2
        case changeGamemode = 3
        case exitEnd = 4
        case demoMessage = 5
        case arrowHittingPlayer = 6
        case fadeValue = 7
        case fadeTime = 8
        case playElderGuardianMobApperance = 9
    }

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        let actionID = try Byte(from: buffer)
        action = try Action(rawValue: actionID).unwrap(ChangeGameStatePacketError.invalidAction(actionID))
        value = try Float(from: buffer)
    }
}

public enum ChangeGameStatePacketError: Error {
    case invalidAction(Byte)
}
