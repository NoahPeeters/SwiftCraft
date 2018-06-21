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
    public typealias LoginSignalProducer = SignalProducer<UserLoginResponse, AnyError>

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

public enum UserLoginServiceError: Error {
    case failed
}
