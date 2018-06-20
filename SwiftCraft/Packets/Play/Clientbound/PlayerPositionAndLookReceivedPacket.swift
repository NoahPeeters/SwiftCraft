//
//  PlayerPositionAndLookReceivedPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 27.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// The server send the current player location and look direction.
public struct PlayerPositionAndLookReceivedPacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID {
        return PacketID(connectionState: .play, id: 0x2F)
    }

    public let x: Value<Double>
    public let y: Value<Double>
    public let z: Value<Double>
    public let yaw: Value<Float>
    public let pitch: Value<Float>

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        let x = try Double(from: buffer)
        let y = try Double(from: buffer)
        let z = try Double(from: buffer)
        let yaw = try Float(from: buffer)
        let pitch = try Float(from: buffer)

        let flags = try Byte(from: buffer)

        self.x = Value.init(value: x, isRelative: flags & 0x01 != 0)
        self.y = Value.init(value: y, isRelative: flags & 0x01 != 0)
        self.z = Value.init(value: z, isRelative: flags & 0x01 != 0)
        self.yaw = Value.init(value: yaw, isRelative: flags & 0x01 != 0)
        self.pitch = Value.init(value: pitch, isRelative: flags & 0x01 != 0)
    }

    public enum Value<Wrapped> {
        case relative(value: Wrapped)
        case absolute(value: Wrapped)

        init(value: Wrapped, isRelative: Bool) {
            if isRelative {
                self = .relative(value: value)
            } else {
                self = .absolute(value: value)
            }
        }
    }
}
