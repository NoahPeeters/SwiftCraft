//
//  UserLoginService.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Result
import Alamofire
import ReactiveSwift

/// Protocol for a service capable to login the user.
public protocol UserLoginServiceProtocol {

    /// Signal producer for the login response.
    typealias ResponseSignalProducer = SignalProducer<UserLoginResponse, AnyError>

    /// Creates a login request.
    ///
    /// - Parameters:
    ///   - username: The username to login.
    ///   - password: The password to login.
    /// - Returns: A SignalProducer for the login request.
    func login(credentials: UserLoginCredentials, requestUser: Bool) -> ResponseSignalProducer
}

struct UserLoginService: UserLoginServiceProtocol {
    public func login(credentials: UserLoginCredentials, requestUser: Bool) -> ResponseSignalProducer {
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

        // Decode response
        return request.jsonSignalProducer(type: UserLoginResponse.self)
    }
}
