//
//  PrintReactors.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

extension MinecraftClient {
    /// Creates a Reactor which prints chat messages
    ///
    /// - Parameter prefix: A String to show in front of every chat message.
    /// - Returns: The reactor.
    public static func chatPrintReactor(prefix: String = "chat: ") -> Reactor {
        return ClosureReactor<ReceiveChatMessagePacket> { packet, _ in
            print("\(prefix)\(packet.message)")
        }
    }

    /// Creates a reactor which prints every incoming and outgoing packet.
    ///
    /// - Returns: The reactor.
    public static func debugPrintReactor() -> Reactor {
        return DebugPrintReactor()
    }
}

/// A Reactor which prints ever packet.
class DebugPrintReactor: Reactor {
    func didReceivedPacket(_ packet: ReceivedPacket, client: MinecraftClient) throws {
        print(" 🔽 \(packet)")
    }

    func didSendPacket(_ packet: SerializablePacket, client: MinecraftClient) {
        print(" 🔼 \(packet)")
    }
}
