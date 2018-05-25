//
//  Alamofire+Reactive.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Result
import Alamofire
import ReactiveSwift

/// Queue used for alamofire completion handler.
private let alamofireQueue = DispatchQueue(label: "Alamofire queue")

extension DataRequest {
    internal func signalProducer() -> SignalProducer<Data, AnyError> {
        return SignalProducer { observer, lifetime in
            self.responseData(queue: alamofireQueue) { response in
                switch response.result {
                case let .success(data):
                    observer.send(value: data)
                    observer.sendCompleted()
                case let .failure(error):
                    observer.send(error: AnyError(error))
                }
            }

            lifetime.observeEnded(self.cancel)
        }
    }

    internal func stringSignalProducer(encoding: String.Encoding = .utf8) -> SignalProducer<String?, AnyError> {
        return signalProducer().map { data in
            return String(data: data, encoding: encoding)
        }
    }

    internal func jsonSignalProducer<ResponseType: Decodable>(type: ResponseType.Type)
        -> SignalProducer<ResponseType, AnyError> {
        return signalProducer().attemptMap { data in
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(ResponseType.self, from: data)
        }
    }
}
