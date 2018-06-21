//
//  AdvancementsPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Updates the advancments of the player.
public struct AdvancementsPacket: DeserializablePacket, LoginPacketIDProvider {
    public static func packetIndex(context: SerializationContext) -> Int? {
        return 0x4D
    }

    public typealias AdvancementMapping = [Identifier: Advancement]
    public typealias ProgressMapping = [Identifier: [Identifier: Int64?]]

    public let reset: Bool

    public let advancementMapping: AdvancementMapping
    public let identifiers: [Identifier]
    public let progressMapping: ProgressMapping

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        reset = try Bool(from: buffer)
        advancementMapping = try AdvancementMapping(from: buffer)
        identifiers = try [Identifier](from: buffer)
        progressMapping = try ProgressMapping(from: buffer)
    }

    public struct Advancement: DeserializableDataType {
        public let parentID: Identifier?
        public let displayData: DisplayData?
        public let criteria: [Identifier]
        public let requirements: [[Identifier]]

        public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
            parentID = try Identifier?(from: buffer)
            displayData = try DisplayData?(from: buffer)
            criteria = try [Identifier](from: buffer)
            requirements = try [[Identifier]](from: buffer)
        }

        public struct DisplayData: DeserializableDataType {
            public let title: String
            public let description: String
            public let icon: SlotContent
            public let frameType: FrameType
            public let showToast: Bool
            public let hidden: Bool
            public let backgroundTexture: Identifier?
            public let x: Float
            public let y: Float

            /// The type of the frame of the advancement.
            public enum FrameType: Int {
                case task = 0
                case challenge = 1
                case goal = 2
            }

            public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
                title = try String(from: buffer)
                description = try String(from: buffer)
                icon = try SlotContent(from: buffer)

                let frameTypeID = try VarInt32(from: buffer).integer
                frameType = try FrameType(rawValue: frameTypeID)
                    .unwrap(AdvancementsPacketError.invalidFrameType(frameTypeID))

                let flags = try Int32(from: buffer)
                showToast = flags & 0x02 > 0
                hidden = flags & 0x04 > 0
                if flags & 0x01 > 0 {
                    backgroundTexture = try Identifier(from: buffer)
                } else {
                    backgroundTexture = nil
                }

                x = try Float(from: buffer)
                y = try Float(from: buffer)
            }
        }
    }
}

public enum AdvancementsPacketError: Error {
    case invalidFrameType(Int)
}
