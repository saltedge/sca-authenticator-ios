//
//  ConnectionsCoordinator.swift
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

final class ConnectionsCoordinator: Coordinator {
    private var rootViewController: UIViewController
    private var currentViewController: ConnectionsViewController
    private var connectViewCoordinator: ConnectViewCoordinator?
    private var qrCodeCoordinator: QRCodeCoordinator?
    private var viewModel = ConnectionsListViewModel()

    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        self.currentViewController = ConnectionsViewController(viewModel: viewModel)
    }

    func start() {
        viewModel.delegate = self
        rootViewController.navigationController?.pushViewController(currentViewController, animated: true)
    }

    func stop() {
        viewModel.delegate = nil
    }
}

// MARK: - ConnectionsListEventsDelegate
extension ConnectionsCoordinator: ConnectionsListEventsDelegate {
    func addPressed() {
        qrCodeCoordinator = QRCodeCoordinator(rootViewController: currentViewController)
        qrCodeCoordinator?.start()
    }

    func updateViews() {
        currentViewController.updateViewsHiddenState()
    }

    func showEditConnection(id: String) {
        let editVc = EditConnectionViewController(connectionId: id)
        editVc.hidesBottomBarWhenPushed = true
        currentViewController.navigationController?.pushViewController(editVc, animated: true)
    }

    func showSupport(email: String) {
        currentViewController.showSupportMailComposer(withEmail: email)
    }

    func deleteConnection(completion: @escaping () -> ()) {
        currentViewController.navigationController?.showConfirmationAlert(
            withTitle: l10n(.delete),
            message: l10n(.deleteConnectionDescription),
            confirmAction: { _ in
                completion()
            }
        )
    }

    func reconnect(by id: String) {
        connectViewCoordinator = ConnectViewCoordinator(rootViewController: currentViewController, connectionType: .reconnect(id))
        connectViewCoordinator?.start()
    }
}
