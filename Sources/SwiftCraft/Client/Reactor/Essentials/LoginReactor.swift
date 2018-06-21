//
//  LoginReactor.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

extension MinecraftClient {
    /// Handels set compression packets by enabeling or disableing compression.
    ///
    /// - Returns: The requested reactor.
    public static func compressionPacketReactor() -> Reactor {
        return ClosureReactor<SetCompressionPacket> { packet, client in
            if packet.threshold == -1 {
                client.disableCompression()
            } else {
                client.enableCompression(threshold: packet.threshold)
            }
        }
    }

    /// Handels the `EncryptionRequestPacket` by enabeling encryption.
    ///
    /// - Returns: The requested reactor.
    public static func encryptionPacketReactor() -> Reactor {
        return ClosureReactor<EncryptionRequestPacket> { packet, client in
            guard let serverIDData = packet.serverID.data(using: .ascii) else {
                throw EncryptionRequestPacketReactorError.invalidServerID
            }

            try client.startEncryption(
                serverID: serverIDData,
                publicKey: Data(bytes: packet.publicKey),
                verifyToken: Data(bytes: packet.verifyToken))
        }
    }

    /// Handels the login success packets by updating the clients connection state.
    ///
    /// - Returns: The requested reactor.
    public static func loginSuccessPacketReactor() -> Reactor {
        return ClosureReactor<LoginSuccessPacket> { _, client in
            client.connectionState = .play
        }
    }

    /// Handels the join game packet by updateing the dimension.
    ///
    /// - Returns: The requested reactor.
    public static func joinGamePacketReactor() -> Reactor {
        return ClosureReactor<JoinGamePacket> { packet, client in
            client.dimension = packet.dimension
        }
    }

    /// Handels all packets relevant for the login.
    ///
    /// - Returns: The requested reactor.
    public static func loginReactor() -> Reactor {
        return MultiReactor(reactors: [
            compressionPacketReactor(),
            encryptionPacketReactor(),
            loginSuccessPacketReactor(),
            joinGamePacketReactor()
        ])
    }
}

/// Errors which can occure while handling encrytion request packets.
public enum EncryptionRequestPacketReactorError: Error {
    /// The given server id is not valid ascii.
    case invalidServerID
}
