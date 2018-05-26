//
//  ClosureReactor.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 26.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// A subclass of `SingleReactor` wich allows a closure to be called on packet receiving.
open class ClosureReactor<PacketType: ReceivedPacket>: SingleReactor<PacketType> {
    /// The type of the closure.
    public typealias Handler = (PacketType, MinecraftClient) throws -> Void

    /// THe handler for new packets.
    private let handler: Handler

    /// Creates a new `ClosureReactor`.
    ///
    /// - Parameter handler: The handler to call.
    public init(handler: @escaping Handler) {
        self.handler = handler
    }

    override open func didReceivedPacket(_ packet: PacketType, client: MinecraftClient) throws {
        try handler(packet, client)
    }
}
