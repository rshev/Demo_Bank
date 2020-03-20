//
//  TransactionFeedEndpoints.swift
//  StarlingTest
//
//  Created by asdfgh1 on 20/03/2020.
//  Copyright © 2020 Roman Shevtsov. All rights reserved.
//

import Foundation

struct GetTransactionFeedEndpoint: Endpoint {
    typealias Response = TransactionFeed

    private enum Constant {
        static let changesSince = "changesSince"
    }

    private let dateFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = .withInternetDateTime
        return dateFormatter
    }()

    var urlPath: String {
        return "/api/v2/feed/account/\(accountUid)/category/\(categoryUid)"
    }

    let httpMethod: HTTPMethod = .GET

    func getRequest() throws -> Request? {
        let date = dateFormatter.string(from: changesSince)
        return .queryParameters([
            URLQueryItem(name: Constant.changesSince, value: date)
        ])
    }

    var accountUid: AccountUid
    var categoryUid: CategoryUid
    var changesSince: Date
}
