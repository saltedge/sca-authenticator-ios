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
    func revoke(_ consent: SEConsentData) {
        currentViewController.showConfirmationAlert(
            withTitle: "Revoke consent",
            message: "Fentury service that is provided to you may be interrupted. Are you sure you want to revoke consent?",
            confirmActionTitle: l10n(.confirm),
            confirmActionStyle: .destructive,
            confirmAction: { _ in
                // TODO: finish
                ConsentsInteractor.revoke(
                    consent,
                    success: {
                        print("Success")
                    },
                    failure: { error in
                        print(error)
                    }
                )
            }
        )
    }
}
