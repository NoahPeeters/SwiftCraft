//
//  URLRequest+Helper.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 20.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

extension URLRequest {
    public init<Payload: Encodable>(postRequest url: URL, jsonData: Payload) throws {
        self.init(url: url)

        let jsonEncoder = JSONEncoder()
        httpBody = try jsonEncoder.encode(jsonData)
        httpMethod = "POST"
        setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        setValue("application/json", forHTTPHeaderField: "Accept")
    }
}

extension URLSession {
    public func jsonTask<Response: Decodable>(with urlRequest: URLRequest,
                                              handler: @escaping (Response?) -> Void) -> URLSessionDataTask {

        return dataTask(with: urlRequest) { data, _, _ in
            guard let data = data else {
                handler(nil)
                return
            }

            handler(try? JSONDecoder().decode(Response.self, from: data))
        }
    }
}
