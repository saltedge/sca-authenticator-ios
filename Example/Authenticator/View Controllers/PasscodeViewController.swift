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
    static let logoImageViewTopOffset: CGFloat = AppLayout.screenHeight * 0.14
    static let passcodeViewTopToLogoOffset: CGFloat = AppLayout.screenHeight * 0.08
    static let passcodeViewTopToViewOffset: CGFloat = AppLayout.screenHeight * 0.16
}

final class PasscodeViewController: BaseViewController {
    private lazy var logoImageView = UIImageView()
    private lazy var blockedAlert = UIAlertController()
    private var passcodeView: PasscodeView

    var completeClosure: (() -> ())?

    private var viewModel: PasscodeViewModel

    init(viewModel: PasscodeViewModel) {
        self.viewModel = viewModel
        passcodeView = PasscodeView(viewModel: viewModel)
        super.init(nibName: nil, bundle: .authenticator_main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = viewModel.navigationItemTitle
        passcodeView.delegate = self
        logoImageView.image = #imageLiteral(resourceName: "authenticatorLogo")
        layout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.blockAppIfNeeded()
    }

    func presentWrongPasscodeAlert(message: String) {
        blockedAlert.message = message
        present(blockedAlert, animated: true)
    }

    func dismissWrongPasscodeAlert() {
        blockedAlert.dismiss(animated: true)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension PasscodeViewController: Layoutable {
    func layout() {
        view.addSubview(passcodeView)

        if !viewModel.shouldHideLogo {
            view.addSubview(logoImageView)

            logoImageView.size(Layout.logoImageViewSize)
            logoImageView.centerXToSuperview()
            logoImageView.top(to: view, view.safeAreaLayoutGuide.topAnchor, offset: Layout.logoImageViewTopOffset)

            passcodeView.topToBottom(of: logoImageView, offset: Layout.passcodeViewTopToLogoOffset)
        } else {
            passcodeView.topToSuperview(offset: Layout.passcodeViewTopToViewOffset)
        }

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
        completeClosure?()
    }

    func biometricsPressed() {
        if !BiometricsHelper.biometricsAvailable {
            showConfirmationAlert(
                withTitle: l10n(.biometricsNotAvailable),
                message: l10n(.biometricsNotAvailableDescription),
                confirmActionTitle: l10n(.goToSettings),
                confirmActionStyle: .default,
                cancelTitle: l10n(.cancel),
                confirmAction: { _ in
                    self.viewModel.goToSettings()
                }
            )
        } else {
            viewModel.showBiometrics(
                completion: {
                    self.completeClosure?()
                }
            )
        }
    }

    func wrongPasscode() {
    }
}
