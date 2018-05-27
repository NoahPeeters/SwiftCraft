//
//  SingleReactor.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Reacts to exacly one type of received packet
open class SingleReactor<PacketType: DeserializablePacket>: Reactor {
    /// Creates a new `SingleReactor`.
    public init() {}

    public func didReceivedPacket(_ packet: DeserializablePacket, client: MinecraftClient) throws {
        if let packet = packet as? PacketType {
            try didReceivedPacket(packet, client: client)
        }
    }

    /// Called when a packet of the requested type was received.
    ///
    /// - Parameters:
    ///   - packet: The packet received.
    ///   - client: The client which received the packet.
    /// - Throws: Any error that might occure.
    open func didReceivedPacket(_ packet: PacketType, client: MinecraftClient) throws {}
}
