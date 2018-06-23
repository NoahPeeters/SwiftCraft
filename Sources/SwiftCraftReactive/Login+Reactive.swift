//
//  Login+Reactive.swift
//  SwiftCraftReactive
//
//  Created by Noah Peeters on 02.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import SwiftCraft
import Result
import ReactiveSwift

extension UserLoginService {
    /// The signal producer for a login request.
    public typealias LoginSignalProducer = SignalProducer<UserLoginResponse, AnyError>

    /// Creates a signal producer to login with the given credentials.
    ///
    /// - Parameters:
    ///   - credentials: The credentials to use to login.
    ///   - requestUser: A flag to request more information about the user with the request.
    /// - Returns: A signal producer for a login request.
    public func loginRequest(credentials: UserLoginCredentials, requestUser: Bool) -> LoginSignalProducer {
        return SignalProducer { observer, _ in
            self.login(credentials: credentials, requestUser: requestUser) { result in
                if let result = result {
                    observer.send(value: result)
                    observer.sendCompleted()
                } else {
                    observer.send(error: AnyError(UserLoginServiceError.failed))
                }
            }
        }
    }
}

/// Errors which might be produced by the login request signal producer.
public enum UserLoginServiceError: Error {
    /// The login failed.
    case failed
}
