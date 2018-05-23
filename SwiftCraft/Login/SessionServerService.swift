//
//  SessionServerService.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 22.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Result
import Alamofire
import ReactiveSwift

/// Protocol for a service capable to join a session.
public protocol SessionServerServiceProtcol {

    /// Signal producer for the join response.
    typealias ResponseSignalProducer = SignalProducer<Bool, AnyError>

    /// Creates a request for a joining a session.
    ///
    /// - Parameter serverHash: The server hash for the request.
    /// - Returns:
    func joinSessionRequest(serverHash: String) -> ResponseSignalProducer

    /// Creates a server hash for a join request.
    ///
    /// - Parameters:
    ///   - serverID: The server id received from the encryption request packet.
    ///   - sharedSecret: The shared secret used for encrypting the connection.
    ///   - publicKey: The public key of the server.
    /// - Returns: The server hash.
    func serverHash(serverID: Data, sharedSecret: Data, publicKey: Data) -> String

    /// The username of the session.
    var username: String { get }
}

/// Default session server service for the mojang servers.
public struct SessionServerService: SessionServerServiceProtcol {
    /// The authentication provider
    private let authenticationProvider: AuthenticationProvider

    /// Creates a new session server service.
    ///
    /// - Parameter authenticationProvider: THe authentication provider to use.
    public init(authenticationProvider: AuthenticationProvider) {
        self.authenticationProvider = authenticationProvider
    }

    public var username: String {
        return authenticationProvider.username
    }

    public func joinSessionRequest(serverHash: String) -> ResponseSignalProducer {
        let payload = createpayload(serverHash: serverHash)

        let url = "https://sessionserver.mojang.com/session/minecraft/join"

        // Create request
        let request = Alamofire.request(
            url,
            method: .post,
            parameters: payload,
            encoding: JSONEncoding.default
        )

        // Decode response
        return request.signalProducer().map {
            return $0.count == 0
        }
    }

    public func serverHash(serverID: Data, sharedSecret: Data, publicKey: Data) -> String {
        let hashData = CC.digest(serverID + sharedSecret + publicKey, alg: .sha1)
        return hashData.minecraftHexString()
    }

    /// Creates the payload required for the join session request
    ///
    /// - Parameter serverHash: The server hash to use in the payload.
    /// - Returns: The payload.
    private func createpayload(serverHash: String) -> Parameters {
        return [
            "accessToken": authenticationProvider.accessToken,
            "selectedProfile": authenticationProvider.profileID,
            "serverId": serverHash
        ]
    }
}
