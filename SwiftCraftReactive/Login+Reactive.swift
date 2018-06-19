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
                switch result {
                case let .success(value):
                    observer.send(value: value)
                    observer.sendCompleted()
                case let .failure(error):
                    observer.send(error: AnyError(error))
                }
            }
        }
    }
}
