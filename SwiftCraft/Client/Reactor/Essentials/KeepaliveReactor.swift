//
//  KeepaliveReactor.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

extension MinecraftClient {
    /// Creates a new reactor for keepalive packets.
    ///
    /// - Returns: The new reactor
    public static func keepaliveReactor() -> Reactor {
        return ClosureReactor<KeepaliveRequestPacket> { packet, client in
            client.sendKeepaliveResponsePacket(id: packet.id)
        }
    }
}
