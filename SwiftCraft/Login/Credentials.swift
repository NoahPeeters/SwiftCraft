//
//  Credentials.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation
import Alamofire

public protocol UserLoginCredentials {
    func createPayload(requestUser: Bool) -> Parameters
    var endpoint: String { get }
}

extension UserLoginCredentials {

    /// The agent object send in the authentication request.
    var agent: [String: String] {
        return [
            "name": "Minecraft",
            "version": "1"
        ]
    }
}

public struct UserLoginPasswordCredentials: UserLoginCredentials {
    /// The username.
    public let username: String

    /// The password.
    public let password: String

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    /// Creates new credentials by reading the username and password from the environment variables
    /// `username` and `password`.
    ///
    /// - Returns: The credentials.
    public static func readFromEnvironment() -> UserLoginPasswordCredentials {
        return UserLoginPasswordCredentials(
            username: ProcessInfo.processInfo.environment["username"]!,
            password: ProcessInfo.processInfo.environment["password"]!)
        }

    public let endpoint: String = "authenticate"

    public func createPayload(requestUser: Bool) -> Parameters {
        return [
            "agent": agent,
            "username": username,
            "password": password,
            "requestUser": requestUser
        ]
    }
}

/// Credentials used to refresh a login.
public protocol UserLoginSessionCredentials: UserLoginCredentials {
    /// The access token returned from the server.
    var accessToken: String { get }

    /// The client token returned from the server.
    var clientToken: String { get }
}

extension UserLoginSessionCredentials {
    public var endpoint: String {
        return "refresh"
    }

    public func createPayload(requestUser: Bool) -> Parameters {
        return [
            "agent": agent,
            "accessToken": accessToken,
            "clientToken": clientToken,
            "requestUser": requestUser
        ]
    }
}

public struct SimpleUserLoginSessionCredentials: UserLoginSessionCredentials {
    public let accessToken: String
    public let clientToken: String

    public init(accessToken: String, clientToken: String) {
        self.accessToken = accessToken
        self.clientToken = clientToken
    }
}
