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
    case failureToCreateSavingsGoal
    case failureToTransferIntoSavingsGoal
}

protocol BankManagerProvider: AnyObject {
    func getRoundableAmount(completion: @escaping CompletionWithResult<CurrencyAndAmount>)
    func transferToSavingsGoal(
        amount: CurrencyAndAmount,
        completion: @escaping CompletionWithResult<BankManager.SavingsGoal>
    )
}

final class BankManager: BankManagerProvider {
    private let api: APIProvider

    init(
        api: APIProvider = API()
    ) {
        self.api = api
    }

    private var account: Account?

    // MARK: - Getting accounts, transaction feed and calculating savings goal

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

    // MARK: - Creating a savings goal, transferring money

    struct SavingsGoal {
        var savingsGoalName: String
        var savingsGoalUid: SavingsGoalUid
        var transferUid: TransferUid?
    }

    func transferToSavingsGoal(
        amount: CurrencyAndAmount,
        completion: @escaping CompletionWithResult<SavingsGoal>
    ) {
        guard let account = account else {
            return completion(.failure(BankManagerError.noAccountsFound))
        }

        let name = "Savings Goal \(UUID().uuidString)"
        let createSavingsGoalEndpoint = CreateSavingsGoalEndpoint(
            accountUid: account.accountUid,
            name: name,
            currency: account.currency
        )
        api.request(createSavingsGoalEndpoint) { [weak self] (result) in
            switch result {
            case .success(let response) where response.success:
                self?.transferMoney(
                    amount: amount,
                    intoSavingsGoal: SavingsGoal(
                        savingsGoalName: name,
                        savingsGoalUid: response.savingsGoalUid
                    ),
                    completion: completion
                )
            case .success:
                completion(.failure(BankManagerError.failureToCreateSavingsGoal))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func transferMoney(
        amount: CurrencyAndAmount,
        intoSavingsGoal savingsGoal: SavingsGoal,
        completion: @escaping CompletionWithResult<SavingsGoal>
    ) {
        guard let account = account else {
            return completion(.failure(BankManagerError.noAccountsFound))
        }

        let transferUid = UUID().uuidString
        let addMoneyIntoSavingsGoalEndpoint = AddMoneyIntoSavingsGoalEndpoint(
            accountUid: account.accountUid,
            savingsGoalUid: savingsGoal.savingsGoalUid,
            transferUid: transferUid,
            currencyAndAmount: amount
        )
        api.request(addMoneyIntoSavingsGoalEndpoint) { (result) in
            switch result {
            case .success(let response) where response.success:
                var savingsGoal = savingsGoal
                savingsGoal.transferUid = response.transferUid
                completion(.success(savingsGoal))
            case .success:
                completion(.failure(BankManagerError.failureToTransferIntoSavingsGoal))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Extensions

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
