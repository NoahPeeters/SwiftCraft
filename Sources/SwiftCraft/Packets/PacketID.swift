//
//  PacketID.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// The id of a packet
public struct PacketID: Hashable {
    /// The state of the connection
    public let connectionState: ConnectionState

    /// The raw id of the packet
    public let id: Int
}

/// The connection state of a connection
public enum ConnectionState: Int, Hashable {
    /// Handshaking.
    case handshaking = 0

    /// The normal game.
    case status = 1

    /// Pinging the server.
    case login = 2

    /// The login process.
    case play = 3

    /// Creates a new packet id.
    ///
    /// - Parameter id: The raw id of the packet.
    /// - Returns: The new packet id.
    public func packetID(with id: Int) -> PacketID {
        return PacketID(connectionState: self, id: id)
    }
}
