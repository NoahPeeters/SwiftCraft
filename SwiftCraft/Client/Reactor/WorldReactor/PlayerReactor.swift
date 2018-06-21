//
//  PlayerReactor.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

extension MinecraftClient {
    public static func playerPositionAndLookReactor(playerManager: PlayerManager) -> Reactor {
        return ClosureReactor<PlayerPositionAndLookReceivedPacket> { packet, _ in
            packet.x.apply(to: &playerManager.playerEntity.x)
            packet.y.apply(to: &playerManager.playerEntity.y)
            packet.z.apply(to: &playerManager.playerEntity.z)
            packet.yaw.apply(to: &playerManager.playerEntity.yaw)
            packet.pitch.apply(to: &playerManager.playerEntity.pitch)
        }
    }
}

public protocol PlayerManager {
    var playerEntity: Entity { get }
}
