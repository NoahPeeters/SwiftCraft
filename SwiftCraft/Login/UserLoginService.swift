//
//  UserLoginService.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Alamofire

/// Protocol for a service capable to login the user.
public protocol UserLoginServiceProtocol {

    /// Response handler for the login response.
    typealias ResponseHandler = (Result<UserLoginResponse>) -> Void

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
    public init() {}

    public func login(credentials: UserLoginCredentials, requestUser: Bool, handler: @escaping ResponseHandler) {
        // Get payload
        let payload = credentials.createPayload(requestUser: requestUser)

        let url = "https://authserver.mojang.com/\(credentials.endpoint)"

        // Create request
        let request = Alamofire.request(
            url,
            method: .post,
            parameters: payload,
            encoding: JSONEncoding.default
        )

        request.asyncJsonResponse(handler)
    }
}
