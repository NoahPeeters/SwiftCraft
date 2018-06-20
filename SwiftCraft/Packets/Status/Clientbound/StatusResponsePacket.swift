//
//  StatusResponsePacket.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Spawns a new object in the world.
public struct StatusResponsePacket: DeserializablePacket {
    public static func packetID(context: SerializationContext) -> PacketID? {
        return PacketID(connectionState: .status, id: 0x00)
    }

    /// The response of the server
    let response: Response

    public init<Buffer: ByteReadBuffer>(from buffer: Buffer, context: SerializationContext) throws {
        let jsonPayload = try Data(from: buffer)

        let jsonDecoder = JSONDecoder()
        response = try jsonDecoder.decode(Response.self, from: jsonPayload)
    }

    /// The response of the server
    public struct Response: Decodable {
        /// Information about the version of the server.
        let version: Version

        /// A description of the server.
        let description: Description

        /// Information about the players on the server.
        let players: PlayersInfo

        /// The favicon of the server. The format is "data:image/png;base64,<data>".
        let favicon: String?

        /// Information about the version of the server.
        public struct Version: Decodable {
            /// The human readable name of the version.
            public let name: String

            /// The version number of the protocol used.
            public let protocolVersion: Int

            private enum CodingKeys: String, CodingKey {
                case name
                case protocolVersion = "protocol"
            }
        }

        /// A description of the server.
        public struct Description: Decodable {
            /// A short text to describe the server.
            let text: String
        }

        /// Information about the players on the server.
        public struct PlayersInfo: Decodable {
            /// The maximum of allowed connection.
            let max: Int

            /// The current number of connections.
            let online: Int

            /// A short list of some connected users. If no user is connected this will be nil.
            let sample: [PlayerSample]?

            /// A entry of the players sample list.
            public struct PlayerSample: Decodable {
                /// The name of the player.
                let name: String

                /// The user id of the player.
                let id: UUID
            }
        }
    }
}
