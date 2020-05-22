//
//  PasscodeViewController
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

private struct Layout {
    static let logoImageViewSize: CGSize = CGSize(width: 72.0, height: 72.0)
    static let logoImageViewTopOffset: CGFloat = 88.0
    static let passcodeViewTopOffset: CGFloat = 68.0
}

final class PasscodeViewController: BaseViewController {
    private let logoImageView = UIImageView()
    private var passcodeView: PasscodeView

    var completeClosure: (() -> ())?

    private var viewModel: PasscodeViewModel

    init(purpose: PasscodeViewModel.PasscodeViewMode) {
        viewModel = PasscodeViewModel(purpose: purpose)
        passcodeView = PasscodeView(viewModel: viewModel)
        super.init(nibName: nil, bundle: .authenticator_main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        passcodeView.delegate = self
        logoImageView.image = #imageLiteral(resourceName: "authenticatorLogo")
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension PasscodeViewController: Layoutable {
    func layout() {
        view.addSubviews(logoImageView, passcodeView)

        logoImageView.size(Layout.logoImageViewSize)
        logoImageView.centerXToSuperview()
        logoImageView.top(to: view, offset: Layout.logoImageViewTopOffset)

        passcodeView.topToBottom(of: logoImageView, offset: Layout.passcodeViewTopOffset)
        passcodeView.centerXToSuperview()
        passcodeView.widthToSuperview()
        passcodeView.bottomToSuperview()
    }
}

// MARK: - PasscodeViewDelegate
extension PasscodeViewController: PasscodeViewDelegate {
    func completed() {
        if viewModel.shouldDismiss {
            close()
        }
        self.completeClosure?()
    }

    func biometricsPressed() {
    }

    func wrongPasscode() {
    }
}
