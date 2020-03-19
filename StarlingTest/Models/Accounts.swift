//
//  Accounts.swift
//  StarlingTest
//
//  Created by asdfgh1 on 19/03/2020.
//  Copyright © 2020 Roman Shevtsov. All rights reserved.
//

import Foundation

struct Accounts: Codable {
    var accounts: [Account]
}

struct Account: Codable {
    var accountUid: AccountUid
    var defaultCategory: CategoryUid
}
