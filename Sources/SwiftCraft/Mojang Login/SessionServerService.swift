//
//  SessionServerService.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 22.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Protocol for a service capable to join a session.
public protocol SessionServerServiceProtocol {
    /// Response handler for the join response.
    typealias ResponseHandler = (Bool) -> Void

    /// Starts a request for a joining a session.
    ///
    /// - Parameters:
    ///   - serverID: The server id received from the encryption request packet.
    ///   - sharedSecret: The shared secret used for encrypting the connection.
    ///   - publicKey: The public key of the server.
    ///   - handler: Completion handler called on success or error
    func joinSession(serverID: Data, sharedSecret: Data, publicKey: Data, handler: @escaping ResponseHandler)

    /// The username of the session.
    var username: String { get }
}

/// Default session server service for the mojang servers.
public struct SessionServerService: SessionServerServiceProtocol {
    /// The authentication provider
    private let authenticationProvider: AuthenticationProvider

    /// URL of the minecraft session server.
    private static let url = URL(string: "https://sessionserver.mojang.com/session/minecraft/join")!

    /// Creates a new session server service.
    ///
    /// - Parameter authenticationProvider: THe authentication provider to use.
    public init(authenticationProvider: AuthenticationProvider) {
        self.authenticationProvider = authenticationProvider
    }

    public var username: String {
        return authenticationProvider.username
    }

    public func joinSession(serverID: Data, sharedSecret: Data, publicKey: Data, handler: @escaping ResponseHandler) {
        let serverHash = calculateServerHash(serverID: serverID, sharedSecret: sharedSecret, publicKey: publicKey)
        let payload = createPayload(serverHash: serverHash)

        guard let request = try? URLRequest(postRequest: SessionServerService.url, jsonData: payload) else {
            handler(false)
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, _ in handler(data?.isEmpty ?? false) }.resume()
    }

    /// Creates a server hash for a join request.
    ///
    /// - Parameters:
    ///   - serverID: The server id received from the encryption request packet.
    ///   - sharedSecret: The shared secret used for encrypting the connection.
    ///   - publicKey: The public key of the server.
    /// - Returns: The server hash.
    private func calculateServerHash(serverID: Data, sharedSecret: Data, publicKey: Data) -> String {
        let hashData = CC.digest(serverID + sharedSecret + publicKey, alg: .sha1)
        return hashData.minecraftHexString()
    }

    /// Creates the payload required for the join session request
    ///
    /// - Parameter serverHash: The server hash to use in the payload.
    /// - Returns: The payload.
    private func createPayload(serverHash: String) -> Payload {
        return Payload(
            accessToken: authenticationProvider.accessToken,
            selectedProfile: authenticationProvider.profileID,
            serverID: serverHash)
    }

    private struct Payload: Encodable {
        let accessToken: String
        let selectedProfile: String
        let serverID: String
    }
}

/// SessionServerService for offline connection.
public struct OfflineSessionService: SessionServerServiceProtocol {
    public func joinSession(serverID: Data, sharedSecret: Data, publicKey: Data, handler: @escaping ResponseHandler) {
        handler(true)
    }

    public let username: String

    /// Creates a new offline session with any username.
    /// If the server is in offline mode the username will not be checked.
    /// If the server is in online mode the client cannot join.
    ///
    /// - Parameter username: The username to login.
    public init(username: String) {
        self.username = username
    }
}
