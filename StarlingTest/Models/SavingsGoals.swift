//
//  SavingsGoals.swift
//  StarlingTest
//
//  Created by asdfgh1 on 19/03/2020.
//  Copyright © 2020 Roman Shevtsov. All rights reserved.
//

import Foundation

struct SavingsGoalRequestV2: Codable {
    var name: String
    var currency: String
}

struct CreateOrUpdateSavingsGoalResponseV2: Codable {
    var savingsGoalUid: SavingsGoalUid
    var success: Bool
}

struct TopUpRequestV2: Codable {
    var amount: CurrencyAndAmount
}

struct SavingsGoalTransferResponseV2: Codable {
    var transferUid: TransferUid
    var success: Bool
}
