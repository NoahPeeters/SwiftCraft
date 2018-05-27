//
//  EntityPropertiesPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 27.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Updates the properties of an entity
public struct EntityPropertiesPacket: SimpleDeserializablePacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x4E)

    /// The id of the entity
    public let entityID: EntityID

    /// The list of properies the entity has.
    public let properies: [Propery]

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        entityID = try VarInt32(from: buffer).value

        let propertiesCount = try Int32(from: buffer)
        properies = try (0..<propertiesCount).map { _ in
            try Propery(from: buffer)
        }
    }

    public struct Propery: DeserializableDataType {
        /// The key of the propery.
        public let key: String

        /// The value of the property.
        public let value: Double

        /// A list of modifiers to apply to the value
        public let modifiers: [Modifier]

        public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
            key = try String(from: buffer)
            value = try Double(from: buffer)
            modifiers = try [Modifier](from: buffer)
        }

        public struct Modifier: DeserializableDataType {
            /// The uuid of the modifier.
            public let uuid: UUID

            /// The operation of the modifer.
            public let operation: Operation

            public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
                uuid = try UUID(from: buffer)

                let operationID = try Byte(from: buffer)
                let value = try Double(from: buffer)

                switch operationID {
                case 0:
                    operation = .add(value: value)
                case 1:
                    operation = .addPercentage(percentage: value)
                case 2:
                    operation = .multiply(value: value)
                default:
                    throw ModifierError.invalidOperation(operationID: operationID)
                }
            }

            /// The operation of a modifier.
            public enum Operation {
                /// Adds a value to the base value.
                case add(value: Double)

                /// Adds a percentage to the base value. Exectuted after add value.
                case addPercentage(percentage: Double)

                /// Multiplies the base value. Executed after add percentage.
                case multiply(value: Double)
            }
        }

        /// A error which might occure while decoding a Modifier.
        enum ModifierError: Error {
            /// The received operation id is invalid.
            case invalidOperation(operationID: Byte)
        }
    }
}
