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
import SEAuthenticatorCore

final class ConnectionsCoordinator: Coordinator {
    private var rootViewController: UIViewController
    private var currentViewController: ConnectionsViewController
    private var connectViewCoordinator: ConnectViewCoordinator?
    private var qrCodeCoordinator: QRCodeCoordinator?
    private var consentsCoordinator: ConsentsCoordinator?
    private var viewModel = ConnectionsViewModel(reachabilityManager: ConnectivityManager.shared)

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
extension ConnectionsCoordinator: ConnectionsEventsDelegate {
    func showNoInternetConnectionAlert(completion: @escaping () -> Void) {
        currentViewController.showConfirmationAlert(
            withTitle: l10n(.noInternetConnection),
            message: l10n(.pleaseCheckAndTryAgain),
            confirmActionTitle: l10n(.retry),
            confirmAction: { _ in completion() }
        )
    }

    func showDeleteConfirmationAlert(completion: @escaping () -> Void) {
        currentViewController.showConfirmationAlert(
            withTitle: l10n(.deleteConnection),
            message: l10n(.deleteConnectionDescription),
            confirmActionTitle: l10n(.delete),
            confirmActionStyle: .destructive,
            cancelTitle: l10n(.cancel),
            confirmAction: { _ in completion() }
        )
    }

    func addPressed() {
        guard AVCaptureHelper.cameraIsAuthorized() else {
            currentViewController.showConfirmationAlert(
                withTitle: l10n(.deniedCamera),
                message: l10n(.deniedCameraDescription),
                confirmActionTitle: l10n(.goToSettings),
                confirmActionStyle: .default,
                cancelTitle: l10n(.cancel),
                confirmAction: { _ in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
            )
            return
        }

        qrCodeCoordinator = QRCodeCoordinator(rootViewController: currentViewController)
        qrCodeCoordinator?.start()
    }

    func updateViews() {
        currentViewController.updateViewsHiddenState()
    }

    func showEditConnectionAlert(placeholder: String, completion: @escaping (String) -> ()) {
        currentViewController.navigationController?.showAlertViewWithInput(
            title: l10n(.rename),
            placeholder: placeholder,
            action: { text in
                completion(text)
            },
            actionTitle: l10n(.rename)
        )
    }

    func showSupport(email: String) {
        currentViewController.showSupportMailComposer(withEmail: email)
    }

    func consentsPressed(connectionId: String, consents: [SEConsentData]) {
        consentsCoordinator = ConsentsCoordinator(
            rootViewController: currentViewController,
            viewModel: ConsentsViewModel(connectionId: connectionId, consents: consents)
        )
        consentsCoordinator?.start()
    }

    func deleteConnection(completion: @escaping () -> ()) {
        currentViewController.navigationController?.showConfirmationAlert(
            withTitle: l10n(.deleteConnection),
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

    func presentError(_ error: String) {
        currentViewController.present(message: error)
    }
}
