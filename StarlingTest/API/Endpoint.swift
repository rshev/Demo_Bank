//
//  Endpoint.swift
//  StarlingTest
//
//  Created by asdfgh1 on 19/03/2020.
//  Copyright © 2020 Roman Shevtsov. All rights reserved.
//

import Foundation

protocol Endpoint {
    associatedtype Response: Codable

    var urlPath: String { get }
    var httpMethod: HTTPMethod { get }
    var request: Request? { get }
}

enum Request {
    case queryParameters([URLQueryItem])
    case body(Data)
}

enum HTTPMethod: String {
    case GET
    case PUT
}

extension Data {
    init<E: Encodable>(jsonEncoded encodable: E) throws {
        self = try JSONEncoder().encode(encodable)
    }
}
