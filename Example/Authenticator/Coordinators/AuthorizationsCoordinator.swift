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

    private var connectViewCoordinator: ConnectViewCoordinator?
    private var passcodeCoordinator: PasscodeCoordinator?

    private var poller: SEPoller?

    private var connections = ConnectionsCollector.activeConnections

    private var selectedViewModelIndex: Int?
    private var selectedCell: AuthorizationCollectionViewCell?

    private var authorizationFromPush: (connectionId: String, authorizationId: String)?

    private let dataSource = AuthorizationsDataSource()

    func start() {
        rootViewController.dataSource = dataSource
        rootViewController.delegate = self
        setupPolling()
        updateDataSource(with: [])
    }

    func start(with connectionId: String, authorizationId: String) {
        refresh()
        start()
        authorizationFromPush = (connectionId, authorizationId)
    }

    func stop() {
        poller?.stopPolling()
        poller = nil
    }

    private func setupPolling() {
        poller = SEPoller(targetClass: self, selector: #selector(getEncryptedAuthorizationsIfAvailable))
        getEncryptedAuthorizationsIfAvailable()
        poller?.startPolling()
    }

    @objc private func getEncryptedAuthorizationsIfAvailable() {
        if poller != nil, connections.count > 0 {
            refresh()
        } else {
            updateDataSource(with: [])
        }
    }

     private func updateDataSource(with authorizations: [SEAuthorizationData]) {
        if dataSource.update(with: authorizations) {
            rootViewController.reloadData()
        }

        if let authorizationToScroll = authorizationFromPush {
            if let viewModel = dataSource.viewModel(
                by: authorizationToScroll.connectionId,
                authorizationId: authorizationToScroll.authorizationId
            ),
            let index = dataSource.index(of: viewModel) {
                rootViewController.scroll(to: index)
            } else {
                rootViewController.present(message: l10n(.authorizationNotFound), style: .error)
            }
            authorizationFromPush = nil
        }

        rootViewController.updateViewsHiddenState()
    }
}

// MARK: - Actions
private extension AuthorizationsCoordinator {
    @objc func refresh() {
        AuthorizationsInteractor.refresh(
            connections: Array(connections),
            success: { [weak self] encryptedAuthorizations in
                guard let strongSelf = self else { return }

                DispatchQueue.global(qos: .background).async {
                    let decryptedAuthorizations = encryptedAuthorizations.compactMap {
                        AuthorizationsPresenter.decryptedData(from: $0)
                    }

                    DispatchQueue.main.async {
                        strongSelf.updateDataSource(with: decryptedAuthorizations)
                    }
                }
            },
            failure: { error in
                print(error)
            },
            connectionNotFoundFailure: { connectionId in
                if let id = connectionId, let connection = ConnectionsCollector.with(id: id) {
                    ConnectionRepository.setInactive(connection)
                }
            }
        )
    }
}

// MARK: - AuthorizationsViewControllerDelegate
extension AuthorizationsCoordinator: AuthorizationsViewControllerDelegate {
    func scanQrPressed() {
        AVCaptureHelper.requestAccess(
            success: {
                guard let navController = self.rootViewController.navigationController else { return }

                self.connectViewCoordinator = ConnectViewCoordinator(
                    rootViewController: navController,
                    connectionType: .connect
                )
                self.connectViewCoordinator?.start()
            },
            failure: {
                self.rootViewController.showConfirmationAlert(
                    withTitle: l10n(.deniedCamera),
                    message: l10n(.deniedCameraDescription),
                    confirmActionTitle: l10n(.goToSettings),
                    confirmActionStyle: .default,
                    confirmAction: { _ in
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }
                )
            }
        )
    }

    func showMainNavigationMenu() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let connections = UIAlertAction(title: l10n(.viewConnections), style: .default) { [weak self] _ in
            guard let navController = self?.rootViewController.navigationController else { return }

            let coordinator = ConnectionsCoordinator(rootViewController: navController)
            coordinator.start()
        }
        let consents = UIAlertAction(title: l10n(.viewConsents), style: .default) { [weak self] _ in
            print("Show Consents")
        }
        let settings = UIAlertAction(title: l10n(.viewSettings), style: .default) { [weak self] _ in
            print("Show Settings")
        }

        for action in [connections, consents, settings, cancel] { actionSheet.addAction($0) }

        rootViewController.present(actionSheet, animated: true)
    }
}
