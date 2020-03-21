//
//  BankManagerTests.swift
//  StarlingTestTests
//
//  Created by asdfgh1 on 21/03/2020.
//  Copyright © 2020 Roman Shevtsov. All rights reserved.
//

import XCTest
@testable import StarlingTest

final class BankManagerTests: XCTestCase {
    private var bankManager: BankManager!
    private var api: APISpy!

    override func setUp() {
        api = APISpy()
        bankManager = BankManager(api: api)
    }

    func testBankManager_whenGetRoundableAmountAndNoAccountsFound_completesWithFailure() {
        api.stubbedRequests["GetAccountsEndpoint"] = .success(Accounts(accounts: []))

        let expectation = self.expectation(description: #function)
        bankManager.getRoundableAmount { (result) in
            switch result {
            case .failure(let error):
                XCTAssertTrue(error.stringEqualsTo(BankManagerError.noAccountsFound), "Should find no accounts")
            default:
                XCTFail("Should complete with failure")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testBankManager_whenGetRoundableAmountAndAccountAndFeedOK_completesWithAmount() {
        api.stubbedRequests["GetAccountsEndpoint"] = .success(Accounts(
            accounts: [
                Account(accountUid: "1", defaultCategory: "2", currency: "GBPAccountCurrency"),
            ]
        ))
        api.stubbedRequests["GetTransactionFeedEndpoint"] = .success(TransactionFeed(
            feedItems: [
                FeedItem(amount: CurrencyAndAmount(minorUnits: 999, currency: "GBP")),
                FeedItem(amount: CurrencyAndAmount(minorUnits: 1000, currency: "GBP")),
                FeedItem(amount: CurrencyAndAmount(minorUnits: 902, currency: "GBP")),
            ]
        ))

        let expectation = self.expectation(description: #function)
        bankManager.getRoundableAmount { (result) in
            switch result {
            case .success(let amount):
                XCTAssertEqual(amount.currency, "GBPAccountCurrency", "Currency should match account currency")
                XCTAssertEqual(amount.minorUnits, 99, "Round up should be 0.01 + 0.00 + 0.98 = 0.99 GBP")
            case .failure:
                XCTFail("Should complete with success")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    // Missed scenarios/improvements (because of time constraints and being very typical to above):
    // - Transfer to savings goal flow
    // - Failure scenarios on every API call
    // - Transfer to savings goal will fail if called before calculating savings goal amount
    // - Check that accounts are not requested more than once if it succeeded the first time
    // - Rounding logic could be extracted into a separate object and tested more extensively
}

class APISpy: APIProvider {
    var invokedRequest = false
    var invokedRequestCount = 0
    var stubbedRequests: [String: Result<Codable, Error>] = [:]

    func request<E: Endpoint>(_ endpoint: E, completion: @escaping (Result<E.Response, Error>) -> Void) {
        invokedRequest = true
        invokedRequestCount += 1
        let endpointType = String(describing: type(of: endpoint))
        if let result = stubbedRequests[endpointType] {
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let value):
                if let value = value as? E.Response {
                    completion(.success(value))
                } else {
                    XCTFail("Supplied wrong type of response for \(endpointType)")
                }
            }
        }
    }
}

extension Error {
    func stringEqualsTo(_ error: Error) -> Bool {
        return String(describing: self) == String(describing: error)
    }
}
