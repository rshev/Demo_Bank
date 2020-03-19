//
//  Common.swift
//  StarlingTest
//
//  Created by asdfgh1 on 19/03/2020.
//  Copyright © 2020 Roman Shevtsov. All rights reserved.
//

import Foundation

typealias AccountUid = String
typealias CategoryUid = String
typealias SavingsGoalUid = String
typealias TransferUid = String

struct CurrencyAndAmount: Codable {
    var minorUnits: Int
}
