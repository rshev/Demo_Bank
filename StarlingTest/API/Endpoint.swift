//
//  Endpoint.swift
//  StarlingTest
//
//  Created by asdfgh1 on 19/03/2020.
//  Copyright © 2020 Roman Shevtsov. All rights reserved.
//

import Foundation

protocol Endpoint {
    associatedtype Request: Codable
    associatedtype Response: Codable

    var urlPath: String { get }
    var httpMethod: HTTPMethod { get }
    var requestBody: Request? { get }
}

enum HTTPMethod: String {
    case GET
    case PUT
}
