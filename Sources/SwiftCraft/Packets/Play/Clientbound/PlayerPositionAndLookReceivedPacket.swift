//
//  PlayerPositionAndLookReceivedPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 27.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// The server send the current player location and look direction.
public struct PlayerPositionAndLookReceivedPacket: DeserializablePacket, PlayPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x2F
    }

    public let x: ValueWrapper<Double>
    public let y: ValueWrapper<Double>
    public let z: ValueWrapper<Double>
    public let yaw: ValueWrapper<Float>
    public let pitch: ValueWrapper<Float>

    public let teleportationID: Int

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        let x = try Double(from: buffer)
        let y = try Double(from: buffer)
        let z = try Double(from: buffer)
        let yaw = try Float(from: buffer)
        let pitch = try Float(from: buffer)

        let flags = try Byte(from: buffer)

        self.x = ValueWrapper(value: x, isRelative: flags & 0x01 != 0)
        self.y = ValueWrapper(value: y, isRelative: flags & 0x02 != 0)
        self.z = ValueWrapper(value: z, isRelative: flags & 0x04 != 0)
        self.yaw = ValueWrapper(value: yaw, isRelative: flags & 0x08 != 0)
        self.pitch = ValueWrapper(value: pitch, isRelative: flags & 0x10 != 0)

        self.teleportationID = try VarInt32(from: buffer).integer
    }

    public enum ValueWrapper<Wrapped> {
        case relative(value: Wrapped)
        case absolute(value: Wrapped)

        public init(value: Wrapped, isRelative: Bool) {
            if isRelative {
                self = .relative(value: value)
            } else {
                self = .absolute(value: value)
            }
        }
    }
}

extension PlayerPositionAndLookReceivedPacket.ValueWrapper where Wrapped: Numeric {
    public func apply(to target: inout Wrapped) {
        switch self {
        case let .relative(value):
            target += value
        case let .absolute(value):
            target = value
        }
    }
}

extension PlayerPositionAndLookReceivedPacket.ValueWrapper where Wrapped == Float {
    public func apply(to target: inout Double) {
        switch self {
        case let .relative(value):
            target += Double(value)
        case let .absolute(value):
            target = Double(value)
        }
    }
}
