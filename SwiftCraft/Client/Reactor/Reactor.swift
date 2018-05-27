//
//  Reactor.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Reacts to packets.
public protocol Reactor {
    /// Handels a received packet.
    ///
    /// - Parameters:
    ///   - packet: The received packet.
    ///   - client: The client which received the packet.
    /// - Throws: Any error which might occure.
    func didReceivedPacket(_ packet: DeserializablePacket, client: MinecraftClient) throws

    /// Decides whether the packet should be send or not.
    ///
    /// - Parameters:
    ///   - packet: The packet to check.
    ///   - client: The client which will send the packet.
    /// - Returns: Whether this reactor want this message to be send or not.
    func shouldSendPacket(_ packet: SerializablePacket, client: MinecraftClient) -> Bool

    /// Called after a packet was send. The reactor might want to react.
    ///
    /// - Parameters:
    ///   - packet: The packet which was send.
    ///   - client: The client which send the packet.
    func didSendPacket(_ packet: SerializablePacket, client: MinecraftClient)
}

extension Reactor {
    public func didReceivedPacket(_ packet: DeserializablePacket, client: MinecraftClient) {}

    public func shouldSendPacket(_ packet: SerializablePacket, client: MinecraftClient) -> Bool {
        return true
    }

    public func didSendPacket(_ packet: SerializablePacket, client: MinecraftClient) {}
}

extension MinecraftClient {
    /// A reactor which handels all essential packets to login and keep the connection alive.
    ///
    /// - Returns: The requested reactor.
    public static func essentialReactors() -> Reactor {
        return MultiReactor(reactors: [
            loginReactor(),
            keepaliveReactor()
        ])
    }
}
