//
//  Alamofire+Helper.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Alamofire

/// Queue used for alamofire completion handler.
private let alamofireQueue = DispatchQueue(label: "Alamofire queue")

extension DataRequest {
    /// Starts a request and handles the response on a background queue.
    ///
    /// - Parameter completionHandler: A callback called after a success or failure.
    internal func asyncDataResponse(completionHandler: @escaping (Result<Data>) -> Void) {
        self.responseData(queue: alamofireQueue) {
            completionHandler($0.result)
        }
    }

    /// Starts a request and decodes the json response on a background queue.
    ///
    /// - Parameter handler: A callback called after a success or failure.
    internal func asyncJsonResponse<ResponseType: Decodable>(_ handler: @escaping (Result<ResponseType>) -> Void) {
        self.asyncDataResponse {
            handler($0.flatMap {
                let jsonDecoder = JSONDecoder()
                return try jsonDecoder.decode(ResponseType.self, from: $0)
            })
        }
    }
}
