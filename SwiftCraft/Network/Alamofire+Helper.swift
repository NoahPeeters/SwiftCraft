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
    internal func asyncDataResponse(completionHandler: @escaping (Result<Data>) -> Void) {
        self.responseData(queue: alamofireQueue) {
            completionHandler($0.result)
        }
    }

    internal func asyncJsonResponse<ResponseType: Decodable>(_ handler: @escaping (Result<ResponseType>) -> Void) {
        self.asyncDataResponse {
            handler($0.flatMap {
                let jsonDecoder = JSONDecoder()
                return try jsonDecoder.decode(ResponseType.self, from: $0)
            })
        }
    }
}
