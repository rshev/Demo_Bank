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
    private let api: API

    init(
        api: API = API()
    ) {
        self.api = api
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

    }

    private func startOver() {
        viewData = .initial
        propagateViewData(
            appendingMessage: "📚 Requesting accounts...",
            changingCTAState: .loading
        )

        let getAccounts = GetAccountsEndpoint()
        api.request(getAccounts) { [weak self] (result) in
            switch result {
            case .success(let accounts):
                self?.progress(withAccounts: accounts)
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
        presenter?.propagate(viewData: viewData)
    }

    private func handle(error: Error) {
        propagateViewData(
            appendingMessage: "❌ Error received: \(error.localizedDescription)",
            changingCTAState: .startOver
        )
    }

    private func progress(withAccounts accounts: Accounts) {
        
    }
}
