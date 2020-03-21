//
//  ViewModelTests.swift
//  StarlingTestTests
//
//  Created by asdfgh1 on 21/03/2020.
//  Copyright © 2020 Roman Shevtsov. All rights reserved.
//

import XCTest
@testable import StarlingTest

final class ViewModelTests: XCTestCase {
    private var bankManager: BankManagerSpy!
    private var viewModel: ViewModel!
    private var presenter: ViewModelPresenterSpy!
    private var propagateQueue: DispatchQueue!

    override func setUp() {
        bankManager = BankManagerSpy()
        propagateQueue = DispatchQueue(label: String(describing: type(of: self)))
        viewModel = ViewModel(bankManager: bankManager, propagateQueue: propagateQueue)
        presenter = ViewModelPresenterSpy()
    }

    func testViewModel_whenLoadCalled_propagatesLoadingAndCallsGetRoundableAmount() {
        viewModel.load(presenter: presenter)
        // Making test synchronous by waiting for a sync block to complete in a serial queue
        propagateQueue.sync { }

        XCTAssertEqual(presenter.invokedPropagateCount, 1, "Should propagate 1 time")
        XCTAssertEqual(presenter.invokedPropagateParameters?.viewData.ctaState, .loading, "CTA State should be loading")
        XCTAssertEqual(bankManager.invokedGetRoundableAmountCount, 1, "Should call get roundable amount on Bank Manager")
    }

    func testViewModel_whenLoadCalledAndManagerReturnsError_propagatesStartOverAndError() {
        viewModel.load(presenter: presenter)

        guard let completion = bankManager.invokedGetRoundableAmountParameters?.completion else {
            return XCTFail("Should call get roundable amount on Bank Manager")
        }
        // Simulating BankManager to complete with error
        completion(.failure(BankManagerError.noAccountsFound))

        // Making test synchronous by waiting for a sync block to complete in a serial queue
        propagateQueue.sync { }

        XCTAssertEqual(presenter.invokedPropagateParameters?.viewData.ctaState, .startOver, "CTA State should be start over")
        // Not a definitive test below, but UI would've been very different in a real app
        XCTAssert(presenter.invokedPropagateParameters?.viewData.loggerContent.contains("Error") == true, "Logger should output error")
    }

    func testViewModel_whenLoadCalledAndManagerReadyToTransfer_propagatesTransferState() {
        viewModel.load(presenter: presenter)

        guard let completion = bankManager.invokedGetRoundableAmountParameters?.completion else {
            return XCTFail("Should call get roundable amount on Bank Manager")
        }
        // Simulating BankManager to complete with success
        completion(.success(CurrencyAndAmount(minorUnits: 100, currency: "GBP")))

        // Making test synchronous by waiting for a sync block to complete in a serial queue
        propagateQueue.sync { }

        XCTAssertEqual(presenter.invokedPropagateParameters?.viewData.ctaState, .transfer, "CTA State should be ready to transfer")
    }

    func testViewModel_whenTransferCTARequested_completesTransferAndPropagatesState() {
        viewModel.load(presenter: presenter)

        guard let getRoundableAmountCompletion = bankManager.invokedGetRoundableAmountParameters?.completion else {
            return XCTFail("Should call get roundable amount on Bank Manager")
        }
        // Simulating BankManager to complete with success
        let minorUnits = 100
        getRoundableAmountCompletion(.success(CurrencyAndAmount(minorUnits: minorUnits, currency: "GBP")))

        viewModel.ctaRequested()

        guard let transferToSavingsGoalParameters = bankManager.invokedTransferToSavingsGoalParameters else {
            return XCTFail("Should call transfer to savings goal on Bank Manager")
        }
        // Simulating BankManager to complete transfer
        transferToSavingsGoalParameters.completion(.success(BankManager.SavingsGoal(
            savingsGoalName: "TestName", savingsGoalUid: "TestUID", transferUid: "TestTransferUID"
        )))

        // Making test synchronous by waiting for a sync block to complete in a serial queue
        propagateQueue.sync { }

        XCTAssertEqual(transferToSavingsGoalParameters.amount.minorUnits, minorUnits, "Transfer should complete with requested amount")
        XCTAssertEqual(presenter.invokedPropagateParameters?.viewData.ctaState, .startOver, "CTA State should be start over")
        // Not a definitive test below, but UI would've been very different in a real app
        XCTAssert(presenter.invokedPropagateParameters?.viewData.loggerContent.contains("🎉") == true, "Logger should output success")
    }

    // Missed scenarios (because of time constraints and being very typical to above):
    // - Load called, manager fails, CTA requested -> assert state changed to loading and manager requested again
    // - Transfer to savings failed -> assert state changed to start over and error propagated
    // - Transfer to savings completed, CTA requested -> assert state changed to loading and flow restarted
}

// MARK: - Spies below generated using Swift Mock Generator for Xcode

class ViewModelPresenterSpy: ViewModelPresenter {
    var invokedPropagate = false
    var invokedPropagateCount = 0
    var invokedPropagateParameters: (viewData: ViewModel.ViewData, Void)?
    var invokedPropagateParametersList = [(viewData: ViewModel.ViewData, Void)]()
    func propagate(viewData: ViewModel.ViewData) {
        invokedPropagate = true
        invokedPropagateCount += 1
        invokedPropagateParameters = (viewData, ())
        invokedPropagateParametersList.append((viewData, ()))
    }
}

class BankManagerSpy: BankManagerProvider {
    var invokedGetRoundableAmount = false
    var invokedGetRoundableAmountCount = 0
    var invokedGetRoundableAmountParameters: (completion: CompletionWithResult<CurrencyAndAmount>, Void)?
    var invokedGetRoundableAmountParametersList = [(completion: CompletionWithResult<CurrencyAndAmount>, Void)]()
    func getRoundableAmount(completion: @escaping CompletionWithResult<CurrencyAndAmount>) {
        invokedGetRoundableAmount = true
        invokedGetRoundableAmountCount += 1
        invokedGetRoundableAmountParameters = (completion, ())
        invokedGetRoundableAmountParametersList.append((completion, ()))
    }
    var invokedTransferToSavingsGoal = false
    var invokedTransferToSavingsGoalCount = 0
    var invokedTransferToSavingsGoalParameters: (amount: CurrencyAndAmount, completion: CompletionWithResult<BankManager.SavingsGoal>)?
    var invokedTransferToSavingsGoalParametersList = [(amount: CurrencyAndAmount, completion: CompletionWithResult<BankManager.SavingsGoal>)]()
    func transferToSavingsGoal(
        amount: CurrencyAndAmount,
        completion: @escaping CompletionWithResult<BankManager.SavingsGoal>
    ) {
        invokedTransferToSavingsGoal = true
        invokedTransferToSavingsGoalCount += 1
        invokedTransferToSavingsGoalParameters = (amount, completion)
        invokedTransferToSavingsGoalParametersList.append((amount, completion))
    }
}
