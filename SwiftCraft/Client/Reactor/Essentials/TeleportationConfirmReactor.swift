//
//  TeleportationConfirmReactor.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

extension MinecraftClient {
    /// Creates a new reactor for keepalive packets.
    ///
    /// - Returns: The new reactor
    public static func teleportationConfirmReactor() -> Reactor {
        return ClosureReactor<PlayerPositionAndLookReceivedPacket> { packet, client in
            client.sendTeleportConfirm(teleportID: packet.teleportationID)
        }
    }
}
