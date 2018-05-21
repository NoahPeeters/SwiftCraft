//
//  PacketID.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// The id of a packet
public struct PacketID: Equatable, Hashable {
    /// The state of the connection
    public let connectionState: ConnectionState

    /// The raw id of the packet
    public let id: Int
}

/// The connection state of a connection
///
/// - handshaking: Handshaking.
/// - play: The normal game.
/// - status: Pinging the server.
/// - login: The login process.
public enum ConnectionState: Int, Equatable, Hashable {
    case handshaking = 0
    case status = 1
    case login = 2
    case play = 3

    /// Creates a new packet id.
    ///
    /// - Parameter id: The raw id of the packet.
    /// - Returns: The new packet id.
    public func packetID(with id: Int) -> PacketID {
        return PacketID(connectionState: self, id: id)
    }
}
