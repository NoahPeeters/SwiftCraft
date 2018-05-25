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
    func didReceivedPacket(_ packet: ReceivedPacket, client: MinecraftClient) throws
    func shouldSendPacket(_ packet: EncodablePacket, client: MinecraftClient) -> Bool
    func didSendPacket(_ packet: EncodablePacket, client: MinecraftClient)
}

extension Reactor {
    public func didReceivedPacket(_ packet: ReceivedPacket, client: MinecraftClient) {}

    public func shouldSendPacket(_ packet: EncodablePacket, client: MinecraftClient) -> Bool {
        return true
    }

    public func didSendPacket(_ packet: EncodablePacket, client: MinecraftClient) {}
}

/// Reacts to exacly one type of received packet
open class SingleReactor<PacketType: ReceivedPacket>: Reactor {
    public init() {}

    public func didReceivedPacket(_ packet: ReceivedPacket, client: MinecraftClient) throws {
        if let packet = packet as? PacketType {
            try didReceivedPacket(packet, client: client)
        }
    }

    open func didReceivedPacket(_ packet: PacketType, client: MinecraftClient) throws {}
}

open class ClosureReactor<PacketType: ReceivedPacket>: SingleReactor<PacketType> {
    public typealias Handler = (PacketType, MinecraftClient) throws -> Void

    private let handler: Handler

    public init(handler: @escaping Handler) {
        self.handler = handler
    }

    override open func didReceivedPacket(_ packet: PacketType, client: MinecraftClient) throws {
        try handler(packet, client)
    }
}

open class MultiReactor: Reactor {
    public init(reactors: [Reactor]) {
        self.reactors = reactors
    }

    let reactors: [Reactor]

    public func didReceivedPacket(_ packet: ReceivedPacket, client: MinecraftClient) throws {
        try reactors.forEach {
            try $0.didReceivedPacket(packet, client: client)
        }
    }

    public func shouldSendPacket(_ packet: EncodablePacket, client: MinecraftClient) -> Bool {
        return reactors.reduce(true) {
            return $0 && $1.shouldSendPacket(packet, client: client)
        }
    }

    public func didSendPacket(_ packet: EncodablePacket, client: MinecraftClient) {
        reactors.forEach {
            $0.didSendPacket(packet, client: client)
        }
    }
}

extension MinecraftClient {
    public static func essentialReactors() -> Reactor {
        return MultiReactor(reactors: [
            loginReactor(),
            keepaliveReactor()
        ])
    }
}
