//
//  SingleAuthorizationViewModel
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

import Foundation
import SEAuthenticator
import SEAuthenticatorV2
import SEAuthenticatorCore

protocol SingleAuthorizationViewModelEventsDelegate: class {
    func receivedDetailViewModel(_ detailViewModel: AuthorizationDetailViewModel)
    func shouldClose()
}

final class SingleAuthorizationViewModel {
    private var connection: Connection?
    private var authorizationId: String?
    private var showLocationWarning: Bool = false
    private var detailViewModel: AuthorizationDetailViewModel?

    private var poller: SEPoller?
    weak var delegate: SingleAuthorizationViewModelEventsDelegate?

    init(connectionId: String, authorizationId: String, locationManagement: LocationManagement) {
        guard let connection = ConnectionsCollector.with(id: connectionId) else { return }

        self.authorizationId = authorizationId
        self.connection = connection
        self.showLocationWarning = locationManagement.shouldShowLocationWarning(connection: connection)

        getAuthorization()
    }

    deinit {
        stopPolling()
    }

    private func getAuthorization() {
        guard let connection = connection, let authorizationId = authorizationId else { return }

        AuthorizationsInteractor.refresh(
            connection: connection,
            authorizationId: authorizationId,
            success: { [weak self] encryptedAuthorization in
                guard let strongSelf = self else { return }

                var decryptedAuthorizationData: SEBaseAuthorizationData?

                if connection.isApiV2 {
                    decryptedAuthorizationData = encryptedAuthorization.decryptedAuthorizationDataV2
                } else {
                    decryptedAuthorizationData = encryptedAuthorization.decryptedAuthorizationData
                }

                guard let data = decryptedAuthorizationData else { return }

                DispatchQueue.main.async {
                    if strongSelf.detailViewModel != nil,
                       let dataV2 = data as? SEAuthorizationDataV2 {
                        strongSelf.updateDetailViewModel(status: dataV2.status)
                    } else if let viewModel = AuthorizationDetailViewModel(data, apiVersion: connection.apiVersion) {
                        strongSelf.detailViewModel = viewModel
                        strongSelf.detailViewModel?.delegate = self

                        strongSelf.delegate?.receivedDetailViewModel(viewModel)
                    }
                }
            },
            failure: { error in
                Log.debugLog(message: error)
            },
            connectionNotFoundFailure: { connectionId in
                if let id = connectionId, let connection = ConnectionsCollector.with(id: id) {
                    ConnectionRepository.setInactive(connection)
                }
            }
        )
    }
}

// MARK: - Polling
extension SingleAuthorizationViewModel {
    func stopPolling() {
        poller?.stopPolling()
        poller = nil
    }

    private func setupPolling() {
        if poller == nil {
            poller = SEPoller(targetClass: self, selector: #selector(getEncryptedAuthorizationIfAvailable))
            getEncryptedAuthorizationIfAvailable()
            poller?.startPolling()
        }
    }

    @objc private func getEncryptedAuthorizationIfAvailable() {
        if poller != nil, connection != nil {
            getAuthorization()
        }
    }
}

// MARK: - AuthorizationDetailEventsDelegate
extension SingleAuthorizationViewModel: AuthorizationDetailEventsDelegate {
    func confirmPressed(_ authorizationId: String, apiVersion: ApiVersion) {
        guard let detailViewModel = detailViewModel, let connection = connection, let url = connection.baseUrl else { return }

        let confirmData = SEConfirmAuthorizationRequestData(
            url: url,
            connectionGuid: connection.guid,
            accessToken: connection.accessToken,
            appLanguage: UserDefaultsHelper.applicationLanguage,
            authorizationId: authorizationId,
            authorizationCode: detailViewModel.authorizationCode
            // NOTE: Temporarily inactive due to legal restrictions
            // geolocation: LocationManager.currentLocation?.headerValue,
            // authorizationType: PasscodeCoordinator.lastAppUnlockCompleteType.rawValue
        )

        detailViewModel.state.value = .processing

        AuthorizationsInteractor.confirm(
            apiVersion: detailViewModel.apiVersion,
            data: confirmData,
            successV1: {
                self.updateDetailViewModel(status: .confirmed)
            },
            successV2: { response in
                if response.status.isFinal {
                    self.updateDetailViewModel(status: .confirmed)
                }
            },
            failure: { _ in
                self.updateDetailViewModel(status: .error)
            }
        )

        setupPolling()
    }

    func denyPressed(_ authorizationId: String, apiVersion: ApiVersion) {
        guard let detailViewModel = detailViewModel, let connection = connection, let url = connection.baseUrl else { return }

        let confirmData = SEConfirmAuthorizationRequestData(
            url: url,
            connectionGuid: connection.guid,
            accessToken: connection.accessToken,
            appLanguage: UserDefaultsHelper.applicationLanguage,
            authorizationId: authorizationId,
            authorizationCode: detailViewModel.authorizationCode
            // NOTE: Temporarily inactive due to legal restrictions
            // geolocation: LocationManager.currentLocation?.headerValue,
            // authorizationType: PasscodeCoordinator.lastAppUnlockCompleteType.rawValue
        )

        detailViewModel.state.value = .processing

        AuthorizationsInteractor.deny(
            apiVersion: detailViewModel.apiVersion,
            data: confirmData,
            successV1: {
                self.updateDetailViewModel(status: .denied)
            },
            successV2: { response in
                if response.status.isFinal {
                    self.updateDetailViewModel(status: .denied)
                }
            },
            failure: { _ in
                self.updateDetailViewModel(status: .error)
            }
        )

        setupPolling()
    }

    func authorizationExpired() {
        detailViewModel?.state.value = .timeOut
        after(finalAuthorizationTimeToLive) {
            self.delegate?.shouldClose()
        }
    }

    private func updateDetailViewModel(status: AuthorizationStatus) {
        guard let state = AuthorizationStateView.AuthorizationState(rawValue: status.rawValue) else { return }

        detailViewModel?.state.value = state
        detailViewModel?.actionTime = Date()

        if status.isFinal {
            stopPolling()
            after(finalAuthorizationTimeToLive) {
                self.delegate?.shouldClose()
            }
        }
    }
}
