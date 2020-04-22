//
//  NewPasscodeViewController
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2020 Salt Edge Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, version 3 or later.
//
//  This program is distributed in the hope that it will be useful, but
//  WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//  General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <http://www.gnu.org/licenses/>.
//
//  For the additional permissions granted for Salt Edge Authenticator
//  under Section 7 of the GNU General Public License see THIRD_PARTY_NOTICES.md
//

import UIKit

final class NewPasscodeViewController: UIViewController {
    private let logoImageView = UIImageView()
    private var passcodeView: PasscodeView

    var completeClosure: (() -> ())?

    private var viewModel: PasscodeViewModel

    init(purpose: PasscodeView.Purpose) {
        viewModel = PasscodeViewModel(purpose: purpose)
        passcodeView = PasscodeView(viewModel: viewModel)
        super.init(nibName: nil, bundle: .authenticator_main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        passcodeView.delegate = self
        view.backgroundColor = .backgroundColor
        logoImageView.image = #imageLiteral(resourceName: "authenticatorLogo")
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Actions
extension NewPasscodeViewController {
    @objc func close() {
        dismiss(animated: true)
    }
}

// MARK: - Layout
extension NewPasscodeViewController: Layoutable {
    func layout() {
        view.addSubviews(logoImageView, passcodeView)

        logoImageView.size(CGSize(width: 72.0, height: 72.0))
        logoImageView.centerXToSuperview()
        logoImageView.top(to: view, offset: 88.0)

        passcodeView.topToBottom(of: logoImageView, offset: 68.0)
        passcodeView.centerXToSuperview()
        passcodeView.widthToSuperview()
        passcodeView.bottomToSuperview()
    }
}

// MARK: - PasscodeViewDelegate
extension NewPasscodeViewController: PasscodeViewDelegate {
    func completed() {
        dismiss(animated: true)
        self.completeClosure?()
    }

    func biometricsPressed() {
    }

    func wrongPasscode() {
    }
}
