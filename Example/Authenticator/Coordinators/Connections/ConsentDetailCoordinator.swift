//
//  ConsentDetailCoordinator
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
import SEAuthenticator

final class ConsentDetailCoordinator: Coordinator {
    private var rootViewController: UIViewController
    private var currentViewController: ConsentDetailViewController
    private var viewModel: ConsentDetailViewModel

    init(rootViewController: UIViewController, viewModel: ConsentDetailViewModel) {
        self.viewModel = viewModel
        self.rootViewController = rootViewController
        self.currentViewController = ConsentDetailViewController()
        self.currentViewController.viewModel = viewModel
    }

    func start() {
        viewModel.delegate = self
        rootViewController.navigationController?.pushViewController(currentViewController, animated: true)
    }

    func stop() {}
}

// MARK: - ConsentDetailViewModelEventsDelegate
extension ConsentDetailCoordinator: ConsentDetailViewModelEventsDelegate {
    func revoke(_ consent: SEConsentData, messageTitle: String, messageDescription: String, successMessage: String) {
        currentViewController.showConfirmationAlert(
            withTitle: messageTitle,
            message: messageDescription,
            confirmActionTitle: l10n(.confirm),
            confirmActionStyle: .destructive,
            confirmAction: { _ in
                ConsentsInteractor.revoke(
                    consent,
                    success: { [weak self] in
                        guard let consentsListVc = self?.rootViewController as? ConsentsViewController else { return }

                        self?.currentViewController.navigationController?.popViewControllerWithHandler(
                            controller: consentsListVc,
                            completion: {
                                consentsListVc.viewModel.remove(consent: consent)
                                consentsListVc.present(message: successMessage)
                            }
                        )
                    },
                    failure: { _ in
                        self.currentViewController.present(message: l10n(.somethingWentWrong))
                    }
                )
            }
        )
    }
}
