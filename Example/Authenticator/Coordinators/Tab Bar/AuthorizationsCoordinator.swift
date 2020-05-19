//
//  AuthorizationCoordinator.swift
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2019 Salt Edge Inc.
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

final class AuthorizationsCoordinator: Coordinator {
    let rootViewController = AuthorizationsViewController()
    private let viewModel = AuthorizationsViewModel()
    private var connectViewCoordinator: ConnectViewCoordinator?

    func start() {
        rootViewController.viewModel = viewModel
        rootViewController.delegate = self
    }

    func start(with connectionId: String, authorizationId: String) {
        viewModel.authorizationFromPush = (connectionId: connectionId, authorizationId: authorizationId)
        start()
    }

    func stop() {
        viewModel.stopPolling()
    }
}

// MARK: - AuthorizationsViewControllerDelegate
extension AuthorizationsCoordinator: AuthorizationsViewControllerDelegate {
    func scanQrPressed() {
        guard let navController = self.rootViewController.navigationController else { return }

        connectViewCoordinator = ConnectViewCoordinator(
            rootViewController: navController,
            connectionType: .connect
        )
        connectViewCoordinator?.start()
    }
}
