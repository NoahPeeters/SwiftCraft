//
//  UserLoginService.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Protocol for a service capable to login the user.
public protocol UserLoginServiceProtocol {
    /// Response handler for the login response.
    typealias ResponseHandler = (UserLoginResponse?) -> Void

    /// Starts a login.
    ///
    /// - Parameters:
    ///   - username: The username to login.
    ///   - password: The password to login.
    ///   - handler: Completion handler called on success or error
    func login(credentials: UserLoginCredentials, requestUser: Bool, handler: @escaping ResponseHandler)
}

/// The login server for the default mojang servers.
public struct UserLoginService: UserLoginServiceProtocol {
    /// Creates a new user login service.
    public init() {}

    /// Base url for authentication.
    private static let url = URL(string: "https://authserver.mojang.com")!

    /// Starts the login request with the given credentials.
    ///
    /// - Parameters:
    ///   - credentials: The credentials to use for the login.
    ///   - requestUser: Flag if the user object is requested as well.
    ///   - handler: A callback called after a success or failure.
    public func login(credentials: UserLoginCredentials, requestUser: Bool, handler: @escaping ResponseHandler) {
        // Get payload
        guard let request = try? credentials.createRequest(baseURL: UserLoginService.url,
                                                           requestUser: requestUser) else {
            handler(nil)
            return
        }

        URLSession.shared.jsonTask(with: request, handler: handler).resume()
    }
}
