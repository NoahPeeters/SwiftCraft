//
//  MinecraftClient.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Minimal protocol for a minecraft client
public protocol MinecraftClientProtocol {
    /// The current connection state. This will influence the interpretation of packet ids.
    var connectionState: ConnectionState { get }

    /// The version number used for the protocol
    var protocolVersion: Int { get }

    /// The current dimension of the player
    var dimension: Dimension { get }
}

/// Baseclass for the library. It manages everything a client have to do.
open class MinecraftClient: MinecraftClientProtocol {
    public private(set) var networkLayer: MinecraftClientNetworkLayer

    /// Service to manage the authorization at mojang's session service.
    public let sessionServerService: SessionServerServiceProtocol

    /// The current connection state. This will influence the interpretation of packet ids.
    public var connectionState = ConnectionState.handshaking

    /// List of `Reactors`. They handle incomming and outgoing messages.
    public private(set) var reactors: [UUID: Reactor] = [:]

    /// The version number used for the protocol
    public private(set) var protocolVersion: Int = 0

    /// Creates a new `MinecraftClient`
    ///
    /// - Parameters:
    ///   - tcpClient: The client used to connect to the server.
    ///   - packetLibrary: The packet library to use for packet deserializing.
    ///   - sessionServerService: The session server service used for authenticating.
    public init(networkLayer: MinecraftClientNetworkLayer,
                sessionServerService: SessionServerServiceProtocol) {
        self.networkLayer = networkLayer
        self.sessionServerService = sessionServerService
        self.networkLayer.delegate = self
    }

    /// Connects to the server and starts the login.
    public func connectAndLogin(protocolVersion: Int? = nil) -> Bool {
        guard let protocolVersion = protocolVersion else {
            var reactorID: UUID!
            reactorID = addReactor(ClosureReactor<StatusResponsePacket> { packet, _ in
                self.removeReactor(with: reactorID)
                self.networkLayer.close()
                _ = self.connectAndLogin(protocolVersion: packet.response.version.protocolVersion)
            })
            return connectAndRequestStatus()
        }

        self.protocolVersion = protocolVersion
        guard networkLayer.connect() else {
            return false
        }
        connectionState = .handshaking
        sendHandshake(nextState: .login)
        connectionState = .login
        sendLoginStart(username: sessionServerService.username)
        return true
    }

    public func connectAndRequestStatus() -> Bool {
        self.protocolVersion = MinecraftClient.mostRecentSupportedProtocolVersion
        guard networkLayer.connect() else {
            return false
        }
        connectionState = .handshaking
        sendHandshake(nextState: .status)
        connectionState = .status
        sendStatusRequestPacket()
        return true
    }

    /// Sends a packet to the server.
    ///
    /// - Parameter packet: The packet to send.
    public func sendPacket(_ packet: SerializablePacket) {
        do {
            if shouldSendPacket(packet, client: self) {
                try networkLayer.sendPacket(packet)
                try didSendPacket(packet, client: self)
            }
        } catch {
            print(" ❌ \(error)")
        }
    }

    /// Starts the encryption procedure and session authentication.
    ///
    /// - Parameters:
    ///   - serverID: The server id from the `EncryptionRequestPacket`.
    ///   - publicKey: The servers public key from the `EncryptionRequestPacket`.
    ///   - verifyToken: Teh verification token from the `EncryptionRequestPacket`.
    /// - Throws: Encryption errors.
    public func startEncryption(serverID: Data, publicKey: Data, verifyToken: Data) throws {
        // Generate shared secret used for aes
        let sharedSecret = try CryptoWrapper.generateRandomData(count: 16)

        // Encrypt data.
        let encryptedVerifyToken = try CryptoWrapper.encrypt(verifyToken, withPublicKey: publicKey)
        let encryptedSharedSecret = try CryptoWrapper.encrypt(sharedSecret, withPublicKey: publicKey)

        let responsePacket = EncryptionResponsePacket(
            encryptedSharedSecret: Array(encryptedSharedSecret),
            encryptedVerifyToken: Array(encryptedVerifyToken))

        // Authenticate with the session server
        sessionServerService.joinSession(serverID: serverID,
                                         sharedSecret: sharedSecret,
                                         publicKey: publicKey) { [weak self] _ in
            self?.sendPacket(responsePacket)
            self?.networkLayer.enableEncryption(sharedSecret: sharedSecret)
        }
    }

    /// Adds a new `Reactor`. This reactor will be called aber any other reactor added so far.
    ///
    /// - Parameter reactor: The reactor to add.
    /// - Returns: A uuid which can be used to remove the reacto
    public func addReactor(_ reactor: Reactor) -> UUID {
        let uuid = UUID()
        reactors[uuid] = reactor
        return uuid
    }

    /// Removes and returns the reactor with the given id.
    ///
    /// - Parameter uuid: The uuid of the reactor to remove.
    /// - Returns: The removed reactor if one with the id existed.
    @discardableResult public func removeReactor(with uuid: UUID) -> Reactor? {
        return reactors.removeValue(forKey: uuid)
    }

    public var dimension: Dimension = .overworld
}

extension MinecraftClient: MinecraftClientNetworkLayerDelegate {
    public var serializationContext: SerializationContext {
        return self
    }

    public func didReceivePacket(_ packet: DeserializablePacket) {
        try? didReceivedPacket(packet, client: self)
    }
}

// MARK: - MinecraftClient+Reactor
extension MinecraftClient: Reactor {
    public func didReceivedPacket(_ packet: DeserializablePacket, client: MinecraftClient) throws {
        try reactors.values.forEach {
            try $0.didReceivedPacket(packet, client: client)
        }
    }

    public func shouldSendPacket(_ packet: SerializablePacket, client: MinecraftClient) -> Bool {
        return reactors.reduce(true) {
            return $0 && $1.value.shouldSendPacket(packet, client: client)
        }
    }

    public func didSendPacket(_ packet: SerializablePacket, client: MinecraftClient) throws {
        try reactors.forEach {
            try $0.value.didSendPacket(packet, client: client)
        }
    }
}
