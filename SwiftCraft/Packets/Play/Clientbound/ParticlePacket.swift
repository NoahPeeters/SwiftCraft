//
//  ParticlePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Spawns a new particle
public struct ParticlePacket: DeserializablePacket, LoginPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x22
    }

    public let particleID: Int
    public let longDistance: Bool

    public let x: Float
    public let y: Float
    public let z: Float

    public let offsetX: Float
    public let offsetY: Float
    public let offsetZ: Float

    public let particleData: Float
    public let count: Int
    public let data: [Int]

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        let particleID = try Int(Int32(from: buffer))
        self.particleID = particleID
        longDistance = try Bool(from: buffer)

        x = try Float(from: buffer)
        y = try Float(from: buffer)
        z = try Float(from: buffer)

        offsetX = try Float(from: buffer)
        offsetY = try Float(from: buffer)
        offsetZ = try Float(from: buffer)

        particleData = try Float(from: buffer)
        count = try Int(Int32(from: buffer))
        data = try [VarInt32](from: buffer, count: ParticlePacket.dataLength(particleID: particleID)).map {
            return $0.integer
        }
    }

    private static func dataLength(particleID: Int) -> Int {
        switch particleID {
        case 36:
            return 2
        case 37, 38, 46:
            return 1
        default:
            return 0
        }
    }
}
