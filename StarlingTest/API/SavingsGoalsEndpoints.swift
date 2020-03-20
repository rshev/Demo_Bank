//
//  SavingsGoalsEndpoints.swift
//  StarlingTest
//
//  Created by asdfgh1 on 20/03/2020.
//  Copyright © 2020 Roman Shevtsov. All rights reserved.
//

import Foundation

struct CreateSavingsGoalEndpoint: Endpoint {
    typealias Response = CreateOrUpdateSavingsGoalResponseV2

    var urlPath: String {
        return "/api/v2/account/\(accountUid)/savings-goals"
    }

    let httpMethod: HTTPMethod = .PUT

    func getRequest() throws -> Request? {
        return .body(try Data(jsonEncoded: SavingsGoalRequestV2(
            name: name,
            currency: currency
        )))
    }

    var accountUid: AccountUid
    var name: String
    var currency: Currency
}

struct AddMoneyIntoSavingsGoalEndpoint: Endpoint {
    typealias Response = SavingsGoalTransferResponseV2

    var urlPath: String {
        return "/api/v2/account/\(accountUid)/savings-goals/\(savingsGoalUid)/add-money/\(transferUid)"
    }

    let httpMethod: HTTPMethod = .PUT

    func getRequest() throws -> Request? {
        return .body(try Data(jsonEncoded: TopUpRequestV2(
            amount: currencyAndAmount
        )))
    }

    var accountUid: AccountUid
    var savingsGoalUid: SavingsGoalUid
    var transferUid: TransferUid
    var currencyAndAmount: CurrencyAndAmount
}
