//
//  LoginReactor.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

extension MinecraftClient {
    public static func compressionPacketReactor() -> Reactor {
        return ClosureReactor<SetCompressionPacket> { packet, client in
            if packet.threshold == -1 {
                client.disableCompression()
            } else {
                client.enableCompression(threshold: packet.threshold)
            }
        }
    }

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

    public static func loginSuccessPacketReactor() -> Reactor {
        return ClosureReactor<LoginSuccessPacket> { _, client in
            client.connectionState = .play
        }
    }

    public static func loginReactor() -> Reactor {
        return MultiReactor(reactors: [
            compressionPacketReactor(),
            encryptionPacketReactor(),
            loginSuccessPacketReactor()
        ])
    }
}

enum EncryptionRequestPacketReactorError: Error {
    case invalidServerID
}
