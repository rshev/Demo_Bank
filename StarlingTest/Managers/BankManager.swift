//
//  BankManager.swift
//  StarlingTest
//
//  Created by asdfgh1 on 20/03/2020.
//  Copyright © 2020 Roman Shevtsov. All rights reserved.
//

import Foundation

enum BankManagerError: Error {
    case noAccountsFound
}

final class BankManager {
    private let api: API

    init(
        api: API = API()
    ) {
        self.api = api
    }

    private var account: Account?

    func getRoundableAmount(completion: @escaping CompletionWithResult<CurrencyAndAmount>) {
        if let account = account {
            getTransactionFeed(account: account) { [weak self] (result) in
                switch result {
                case .success(let feed):
                    self?.calculateSavingsGoalAmount(
                        forAccount: account,
                        transactionFeed: feed,
                        completion: completion
                    )
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            getAccount { [weak self] (result) in
                switch result {
                case .success:
                    self?.getRoundableAmount(completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    private func getAccount(completion: @escaping CompletionWithResult<Accounts>) {
        let getAccountsEndpoint = GetAccountsEndpoint()
        api.request(getAccountsEndpoint) { [weak self] (result) in
            switch result {
            case .success(let accounts) where accounts.accounts.first != nil:
                self?.account = accounts.accounts.first
                completion(result)
            case .success:
                completion(.failure(BankManagerError.noAccountsFound))
            case .failure:
                completion(result)
            }
        }
    }

    private func getTransactionFeed(
        account: Account,
        completion: @escaping CompletionWithResult<TransactionFeed>
    ) {
        let getTransactionFeedEndpoint = GetTransactionFeedEndpoint(
            accountUid: account.accountUid,
            categoryUid: account.defaultCategory,
            changesSince: .weekAgo
        )
        api.request(getTransactionFeedEndpoint) { (result) in
            completion(result)
        }
    }

    private func calculateSavingsGoalAmount(
        forAccount account: Account,
        transactionFeed: TransactionFeed,
        completion: @escaping CompletionWithResult<CurrencyAndAmount>
    ) {
        let amountToRoundUp = transactionFeed.feedItems
            .map { $0.amount.minorUnitsRoundUpToHundred }
            .reduce(0, +)
        let currencyAndAmount = CurrencyAndAmount(
            minorUnits: amountToRoundUp,
            currency: account.currency
        )
        completion(.success(currencyAndAmount))
    }
}

private extension CurrencyAndAmount {
    var minorUnitsRoundUpToHundred: Int {
        if minorUnits % 100 == 0 {
            return 0
        } else {
            return 100 - (minorUnits % 100)
        }
    }
}

extension Date {
    static var weekAgo: Date {
        return daysFromNow(-7)
    }

    static func daysFromNow(_ days: Int) -> Date {
        return Date(timeIntervalSinceNow: TimeInterval(days * 24 * 60 * 60))
    }
}
