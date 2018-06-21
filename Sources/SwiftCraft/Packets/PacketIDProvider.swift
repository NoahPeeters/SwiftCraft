//
//  PacketIDProvider.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Provides the id of a packet.
public protocol PacketIDProvider {
    /// Returns the id of the packet.
    ///
    /// - Parameter context: The current client context.
    /// - Returns: The packet id.
    static func packetID(context: SerializationContext) -> PacketID?
}

/// Provides the packet id by providing the conenction state and index seperatly.
public protocol SimplePacketIDProvider: PacketIDProvider {
    /// Returns the connection state of the packet.
    ///
    /// - Parameter context: The current client context.
    /// - Returns: The packet id.
    static func connectionState(context: SerializationContext) -> ConnectionState?

    /// Returns the packet id index of the packet.
    ///
    /// - Parameter context: The current client context.
    /// - Returns: The index of the packet.
    static func packetIndex(context: SerializationContext) -> Int?
}

extension SimplePacketIDProvider {
    public static func packetID(context: SerializationContext) -> PacketID? {
        guard let connectionState = connectionState(context: context), let index = packetIndex(context: context) else {
            return nil
        }

        return connectionState.packetID(with: index)
    }
}

/// Provides the packet id of a handshake packet.
public protocol HandshakePacketIDProvider: SimplePacketIDProvider {}

extension HandshakePacketIDProvider {
    public static func connectionState(context: SerializationContext) -> ConnectionState? {
        return .handshaking
    }
}

/// Provides the packet id of a status packet.
public protocol StatusPacketIDProvider: SimplePacketIDProvider {}

extension StatusPacketIDProvider {
    public static func connectionState(context: SerializationContext) -> ConnectionState? {
        return .status
    }
}

/// Provides the packet id of a login packet.
public protocol LoginPacketIDProvider: SimplePacketIDProvider {}

extension LoginPacketIDProvider {
    public static func connectionState(context: SerializationContext) -> ConnectionState? {
        return .login
    }
}

/// Provides the packet id of a play packet.
public protocol PlayPacketIDProvider: SimplePacketIDProvider {}

extension PlayPacketIDProvider {
    public static func connectionState(context: SerializationContext) -> ConnectionState? {
        return .play
    }
}
