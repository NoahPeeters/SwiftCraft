//
//  MultiReactor.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// A reactor which forwards all events to any number of reactors.
open class MultiReactor: Reactor {
    /// Creates a new `MultiReactor` with the given child reactors.
    ///
    /// - Parameter reactors: The reactors to notify about events.
    public init(reactors: [Reactor]) {
        self.reactors = reactors
    }

    /// The reactors to notify about events.
    private let reactors: [Reactor]

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
