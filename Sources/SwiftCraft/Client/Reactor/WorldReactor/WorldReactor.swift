//
//  WorldReactor.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 27.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

extension MinecraftClient {
    /// Handels all packets relevant for world status updates.
    ///
    /// - Returns: The requested reactor.
    public static func worldReactor(worldStatusManager: MinecraftWorldStatusManager) -> Reactor {
        return MultiReactor(reactors: [
            chunkDataReactor(blockManager: worldStatusManager),
            unloadChunkReactor(blockManager: worldStatusManager),
            blockChangeReactor(blockManager: worldStatusManager),
            multiBlockChangeReactor(blockManager: worldStatusManager),
            playerPositionAndLookReactor(playerManager: worldStatusManager)
        ])
    }
}

/// Manager for the world status
public typealias MinecraftWorldStatusManager = BlockManager & PlayerManager
