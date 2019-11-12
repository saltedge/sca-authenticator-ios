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

    private var passcodeCoordinator: PasscodeCoordinator?

    private var timer: Timer?
    private let dataSource = AuthorizationsDataSource()
    private var connections = ConnectionsCollector.activeConnections

    private var selectedViewModelIndex: Int?
    private var selectedCell: AuthorizationCollectionViewCell?

    private var authorizationFromPush: (connectionId: String, authorizationId: String)?

    func start() {
        rootViewController.dataSource = dataSource
        rootViewController.delegate = self

        setupPolling()
        updateDataSource(with: [])
    }

    func start(with connectionId: String, authorizationId: String) {
        start()
        authorizationFromPush = (connectionId, authorizationId)
    }

    func stop() {
        timer?.invalidate()
    }

    private func setupPolling() {
        getEncryptedAuthorizationsIfAvailable()

        timer = Timer.scheduledTimer(
            timeInterval: 2.0,
            target: self,
            selector: #selector(getEncryptedAuthorizationsIfAvailable),
            userInfo: nil,
            repeats: true
        )
    }

    @objc private func getEncryptedAuthorizationsIfAvailable() {
        if connections.count > 0 {
            refresh()
        } else {
            updateDataSource(with: [])
        }
    }

     private func updateDataSource(with authorizations: [SEDecryptedAuthorizationData]) {
        if dataSource.update(with: authorizations) {
            rootViewController.reloadData()
            if authorizations.count > 1,
                let authorizationToScroll = authorizationFromPush,
                let viewModel = dataSource.viewModel(
                    by: authorizationToScroll.connectionId,
                    authorizationId: authorizationToScroll.authorizationId
                ),
                let index = dataSource.index(of: viewModel) {
                    rootViewController.scroll(to: index)
                    authorizationFromPush = nil
            }
        }
        rootViewController.updateViewsHiddenState()
    }

    private func confirmationData(for index: Int) -> SEConfirmAuthorizationData? {
        guard let viewModel = dataSource.viewModel(at: index),
            let connection = ConnectionsCollector.with(id: viewModel.connectionId),
            let url = connection.baseUrl else { return nil }

        return SEConfirmAuthorizationData(
            url: url,
            connectionGuid: connection.guid,
            accessToken: connection.accessToken,
            appLanguage: UserDefaultsHelper.applicationLanguage,
            authorizationId: viewModel.authorizationId,
            authorizationCode: viewModel.authorizationCode
        )
    }

    private func authorize(_ data: SEConfirmAuthorizationData, viewModel: AuthorizationViewModel, index: Int) {
        AuthorizationsInteractor.confirm(
            data: data,
            success: {
                self.remove(viewModel, at: index)
            },
            failure: { _ in
                self.setupPolling()
            }
        )
    }

    private func remove(_ viewModel: AuthorizationViewModel, at index: Int) {
        _ = dataSource.remove(viewModel)
        rootViewController.remove(at: index)
        setupPolling()
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
                    let decryptedAuthorizations = encryptedAuthorizations.compactMap { authorization in
                        return AuthorizationsPresenter.decryptedData(from: authorization)
                    }

                    DispatchQueue.main.async {
                        strongSelf.updateDataSource(with: decryptedAuthorizations)
                    }
                }
            },
            connectionNotFoundFailure: { connectionId in
                if let id = connectionId, let connection = ConnectionsCollector.with(id: id) {
                    ConnectionRepository.setInactive(connection)
                }
            }
        )
    }

    func showAndConfirmWithPasscode() {
        passcodeCoordinator = PasscodeCoordinator(
            rootViewController: rootViewController,
            purpose: .enter,
            type: .authorize
        )
        passcodeCoordinator?.onCompleteClosure = { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.selectedCell?.setProcessing(with: l10n(.processing))

            guard let index = strongSelf.selectedViewModelIndex,
                let data = strongSelf.confirmationData(for: index),
                let viewModel = strongSelf.dataSource.viewModel(at: index) else { return }

            strongSelf.authorize(data, viewModel: viewModel, index: index)
        }
        passcodeCoordinator?.onDismissClosure = { [weak self] in
            self?.setupPolling()
        }
        passcodeCoordinator?.start()
    }
}

// MARK: - AuthorizationsViewControllerDelegate
extension AuthorizationsCoordinator: AuthorizationsViewControllerDelegate {
    func denyPressed(at index: Int) {
        guard let data = confirmationData(for: index),
            let viewModel = dataSource.viewModel(at: index) else { return }

        timer?.invalidate()

        AuthorizationsInteractor.deny(
            data: data,
            success: { [weak self] in
                guard let strongSelf = self else { return }

                strongSelf.remove(viewModel, at: index)
            },
            failure: { _ in
                self.setupPolling()
            }
        )
    }

    func confirmPressed(at index: Int, cell: AuthorizationCollectionViewCell) {
        selectedViewModelIndex = index
        selectedCell = cell

        timer?.invalidate()

        guard let data = confirmationData(for: index),
            let viewModel = dataSource.viewModel(at: index) else { return }

        if let authorizationIdFromPush = AppDelegate.main.authorizationIdFromPush,
            viewModel.authorizationId == authorizationIdFromPush || dataSource.rows == 1 {
            AppDelegate.main.authorizationIdFromPush = nil
            cell.setProcessing(with: l10n(.processing))
            self.authorize(data, viewModel: viewModel, index: index)
            return
        }

        guard PasscodeManager.isBiometricsEnabled else { self.showAndConfirmWithPasscode(); return }

        PasscodeManager.useBiometrics(
            type: .authorize,
            reasonString: l10n(.confirmAuthorization),
            onSuccess: { [weak self] in
                guard let strongSelf = self else { return }

                cell.setProcessing(with: l10n(.processing))

                strongSelf.authorize(data, viewModel: viewModel, index: index)
            },
            onFailure: { _ in
                self.showAndConfirmWithPasscode()
            }
        )
    }

    func modalClosed() {
        setupPolling()
    }
}
