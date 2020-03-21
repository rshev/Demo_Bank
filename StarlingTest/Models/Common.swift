//
//  Common.swift
//  StarlingTest
//
//  Created by asdfgh1 on 19/03/2020.
//  Copyright © 2020 Roman Shevtsov. All rights reserved.
//

import Foundation

// Could be structs wrapping Strings to be strongly-typed,
// but for simplicity these are just typealiases
typealias AccountUid = String
typealias CategoryUid = String
typealias SavingsGoalUid = String
typealias TransferUid = String
typealias Currency = String

struct CurrencyAndAmount: Codable {
    var minorUnits: Int
    var currency: Currency
}
