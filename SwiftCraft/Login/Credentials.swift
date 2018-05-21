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
