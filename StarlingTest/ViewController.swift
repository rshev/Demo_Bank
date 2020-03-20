//
//  ViewController.swift
//  StarlingTest
//
//  Created by asdfgh1 on 19/03/2020.
//  Copyright © 2020 Roman Shevtsov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var ctaButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var textView: UITextView!

    private lazy var viewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.load(presenter: self)
    }

    @IBAction func didTapCTAButton() {
        viewModel.ctaRequested()
    }
}

extension ViewController: ViewModelPresenter {
    func propagate(viewData: ViewModel.ViewData) {
        textView.text = viewData.loggerContent

        switch viewData.ctaState {
        case .loading:
            activityIndicator.isHidden = false
            ctaButton.isHidden = true
        case .startOver:
            activityIndicator.isHidden = true
            ctaButton.isHidden = false
            ctaButton.setTitle("Start Over", for: .normal)
        case .transfer:
            activityIndicator.isHidden = true
            ctaButton.isHidden = false
            ctaButton.setTitle("Transfer to savings goal", for: .normal)
        }
    }
}
