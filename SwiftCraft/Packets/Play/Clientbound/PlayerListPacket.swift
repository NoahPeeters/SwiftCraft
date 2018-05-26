//
//  PlayerListPacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Updates for the player list.
public struct PlayerListPacket: ReceivedPacket {
    public static var packetID = PacketID(connectionState: .play, id: 0x2E)

    let action: Action

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        let actionID = try VarInt32(from: buffer).value

        switch actionID {
        case 0:
            action = try .addPlayer(newPlayers: [AddPlayerPayload](from: buffer))
        case 1:
            action = try .updateGamemode(newGamemodes: [PlayerUpdate<Byte>](from: buffer).toDictionary {
                try Gamemode(id: $0).unwrap(PlayerListPacketError.unknownGamemode)
            })
        case 2:
            action = try .updatePings(newPings: [PlayerUpdate<VarInt32>](from: buffer).toDictionary {
                Int($0.value)
            })
        case 3:
            action = try .updateDisplayName(newNames: [PlayerUpdate<String?>](from: buffer).toDictionary())
        case 4:
            action = try .removePlayer(uuids: [UUID](from: buffer))
        default:
            throw PlayerListPacketError.unknownAction(actionID: Int(actionID))
        }
    }

    /// The action of the player list packet.
    public enum Action {
        /// New players joined the server.
        case addPlayer(newPlayers: [AddPlayerPayload])

        /// The gamemode of at least one play has changed.
        case updateGamemode(newGamemodes: [UUID: Gamemode])

        /// THe ping of at least one player has changed.
        case updatePings(newPings: [UUID: Int])

        /// The display name of at least one player has changed.
        case updateDisplayName(newNames: [UUID: String?])

        // At least one player left the server.
        case removePlayer(uuids: [UUID])
    }

    /// The payload of a add player packet.
    public struct AddPlayerPayload: DeserializableDataType {
        /// The uuid of the new player.
        let uuid: UUID

        /// A list of properties of the player.
        let properties: [Property]

        /// The name of the player.
        let name: String

        /// The gamemode of the player.
        let gamemode: Gamemode

        /// The ping to the player.
        let ping: Int

        /// The display name of the player.
        let displayName: String?

        public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
            uuid = try UUID(from: buffer)
            name = try String(from: buffer)
            properties = try [Property](from: buffer)
            gamemode = try Gamemode(id: Byte(from: buffer)).unwrap(PlayerListPacketError.unknownGamemode)
            ping = try VarInt32(from: buffer).integer
            displayName = try String?(from: buffer)
        }

        /// A property of a player.
        struct Property: DeserializableDataType {
            /// The name of the property.
            let name: String

            /// The value of the property
            let value: String

            /// The signature of the propery.
            let signature: String?

            public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
                name = try String(from: buffer)
                value = try String(from: buffer)
                signature = try String?(from: buffer)
            }
        }
    }

    /// Error which might occure while decoding a `PlayerListPacket`.
    enum PlayerListPacketError: Error {
        /// The given gamemode is not valid.
        case unknownGamemode

        /// The action id provided in the packet is unknown.
        case unknownAction(actionID: Int)
    }
}

/// Temporary type for decoding action data.
private struct PlayerUpdate<Payload: DeserializableDataType>: DeserializableDataType {
    /// The uuid of the player.
    let uuid: UUID

    /// The payload of the packet.
    let payload: Payload

    public init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        uuid = try UUID(from: buffer)
        payload = try Payload(from: buffer)
    }
}

extension Array {
    /// Coneverts the payload to a dictionary.
    ///
    /// - Returns: The dictionary.
    fileprivate func toDictionary<Payload>() -> [UUID: Payload] where Element == PlayerUpdate<Payload> {
        return toDictionary { $0 }
    }

    /// Coneverts the payload to a dictionary.
    ///
    /// - Parameter mapper: A function applied to every payload before adding it to the dictionary.
    /// - Returns: The dictionay.
    /// - Throws: Retrhows errors of mapper.
    fileprivate func toDictionary<InPayload, OutPayload>(mapper: (InPayload) throws -> OutPayload) rethrows
        -> [UUID: OutPayload] where Element == PlayerUpdate<InPayload> {
        return try Dictionary.init(uniqueKeysWithValues: map {
            try ($0.uuid, mapper($0.payload))
        })
    }
}
