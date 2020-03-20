//
//  Accounts.swift
//  StarlingTest
//
//  Created by asdfgh1 on 19/03/2020.
//  Copyright © 2020 Roman Shevtsov. All rights reserved.
//

import Foundation

struct GetAccountsEndpoint: Endpoint {
    typealias Response = Accounts

    let urlPath = "/api/v2/accounts"
    let httpMethod: HTTPMethod = .GET
    let request: Request? = nil
}
