//
//  Credentials.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Crenentials which can be used to authenticate with the mojang login servers.
public protocol UserLoginCredentials {
    /// Creates the request to send to the server.
    ///
    /// - Parameter requestUser: Flag if the iuser object is requested as well.
    /// - Returns: The request.
    func createRequest(baseURL: URL, requestUser: Bool) throws -> URLRequest
}

public struct UserLoginCredentialsAgent: Encodable {
    public let name: String
    public let version: String

    public static var `default`: UserLoginCredentialsAgent {
        return UserLoginCredentialsAgent(name: "Minecraft", version: "1")
    }
}

/// Credentials for the mojang authentication server.
///
/// - Attention:
///     When logging in with these credentials multiple times (like 3) in a short period of time from the same ip
///     event if the username and password are correct the ip will be blocked.
public struct UserLoginPasswordCredentials: UserLoginCredentials {

    /// The username.
    public let username: String

    /// The password.
    public let password: String

    /// Creates new credentials with a username and password.
    ///
    /// - Parameters:
    ///   - username: The username to login. Mojang accounts will have to use their email.
    ///   - password: The password to login.
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    private let endpoint: String = "authenticate"

    private func createPayload(requestUser: Bool) -> UserLoginPasswordCredentialsPayload {
        return UserLoginPasswordCredentialsPayload(agent: .default, username: username,
                                                   password: password, requestUser: requestUser)
    }

    public func createRequest(baseURL: URL, requestUser: Bool) throws -> URLRequest {
        return try URLRequest(
            postRequest: baseURL.appendingPathComponent(endpoint),
            jsonData: createPayload(requestUser: requestUser))
    }
}

public struct UserLoginPasswordCredentialsPayload: Encodable {
    public let agent: UserLoginCredentialsAgent
    public let username: String
    public let password: String
    public let requestUser: Bool
}

/// Credentials used to refresh a login.
public protocol UserLoginSessionCredentials: UserLoginCredentials {
    /// The access token returned from the server.
    var accessToken: String { get }

    /// The client token returned from the server.
    var clientToken: String { get }
}

public struct UserLoginSessionCredentialsPayload: Encodable {
    public let agent: UserLoginCredentialsAgent
    public let accessToken: String
    public let clientToken: String
    public let requestUser: Bool
}

extension UserLoginSessionCredentials {
    private var endpoint: String {
        return "refresh"
    }

    private func createPayload(requestUser: Bool) -> UserLoginSessionCredentialsPayload {
        return UserLoginSessionCredentialsPayload(agent: .default, accessToken: accessToken,
                                                  clientToken: clientToken, requestUser: requestUser)
    }

    public func createRequest(baseURL: URL, requestUser: Bool) throws -> URLRequest {
        return try URLRequest(
            postRequest: baseURL.appendingPathComponent(endpoint),
            jsonData: createPayload(requestUser: requestUser))
    }
}

/// Credentials used to refresh a login.
public struct SimpleUserLoginSessionCredentials: UserLoginSessionCredentials {
    public let accessToken: String
    public let clientToken: String

    /// Creates new credentials.
    ///
    /// - Parameters:
    ///   - accessToken: The access token received from the server.
    ///   - clientToken: The client token received from the server.
    public init(accessToken: String, clientToken: String) {
        self.accessToken = accessToken
        self.clientToken = clientToken
    }
}
