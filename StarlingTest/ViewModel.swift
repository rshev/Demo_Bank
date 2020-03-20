//
//  ViewModel.swift
//  StarlingTest
//
//  Created by asdfgh1 on 19/03/2020.
//  Copyright © 2020 Roman Shevtsov. All rights reserved.
//

import Foundation

protocol ViewModelPresenter: AnyObject {
    func propagate(viewData: ViewModel.ViewData)
}

final class ViewModel {
    private let bankManager: BankManager
    private let propagateQueue: DispatchQueue

    init(
        bankManager: BankManager = BankManager(),
        propagateQueue: DispatchQueue = .main
    ) {
        self.bankManager = bankManager
        self.propagateQueue = propagateQueue
    }

    struct ViewData {
        enum CTAState {
            case loading
            case startOver
            case transfer
        }
        var ctaState: CTAState
        var loggerContent: String

        static var initial: ViewData = ViewData(ctaState: .loading, loggerContent: "")
    }
    private var viewData: ViewData = .initial

    private weak var presenter: ViewModelPresenter?

    func load(presenter: ViewModelPresenter) {
        self.presenter = presenter
        startOver()
    }

    func ctaRequested() {
        switch viewData.ctaState {
        case .loading:
            break
        case .startOver:
            startOver()
        case .transfer:
            transferToSavingsGoal()
        }
    }

    private func startOver() {
        viewData = .initial
        propagateViewData(
            appendingMessage: "📚 Requesting accounts and transactions...",
            changingCTAState: .loading
        )

        bankManager.getRoundableAmount { [weak self] (result) in
            switch result {
            case .success(let amount):
                self?.progress(withAmount: amount)
            case .failure(let error):
                self?.handle(error: error)
            }
        }
    }

    private func propagateViewData(
        appendingMessage message: String? = nil,
        changingCTAState ctaState: ViewData.CTAState? = nil
    ) {
        if let message = message {
            viewData.loggerContent += "\(message)\n"
        }
        if let ctaState = ctaState {
            viewData.ctaState = ctaState
        }
        propagateQueue.async { [weak presenter, viewData] in
            presenter?.propagate(viewData: viewData)
        }
    }

    private func handle(error: Error) {
        propagateViewData(
            appendingMessage: "❌ Error received: \(error)",
            changingCTAState: .startOver
        )
    }

    private func progress(withAmount amount: CurrencyAndAmount) {
        propagateViewData(
            appendingMessage: "💰 Ready to set aside \(amount.readableDescription)",
            changingCTAState: .transfer
        )
    }

    private func transferToSavingsGoal() {

    }
}

private extension CurrencyAndAmount {
    var readableDescription: String {
        return "\(Double(minorUnits) / 100.0) \(currency)"
    }
}
