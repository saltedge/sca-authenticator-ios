//
//  AuthorizationsDataSource.swift
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
import SEAuthenticatorV2
import SEAuthenticatorCore

final class AuthorizationsDataSource {
    private var viewModels = [AuthorizationDetailViewModel]()
    private var locationManagement: LocationManagement

    // TODO: Fix geolocation according to new design
    init(locationManagement: LocationManagement) {
        self.locationManagement = locationManagement
    }

    func update(with baseData: [SEBaseAuthorizationData]) -> Bool {
        let viewModelsV1 = baseData.toAuthorizationViewModel(apiVersion: "1")
            .merge(array: self.viewModels.filter { $0.apiVersion == "1" })

        let viewModelsV2 = baseData.toAuthorizationViewModel(apiVersion: "2")
            .merge(array: self.viewModels.filter { $0.apiVersion == "2" })

        let allViewModels = (viewModelsV1 + viewModelsV2).sorted(by: { $0.createdAt < $1.createdAt })

        if allViewModels != self.viewModels {
            self.viewModels = allViewModels
            return true
        }

        let cleared = clearedViewModels()

        if cleared != self.viewModels {
            self.viewModels = cleared
            return true
        }
        return false
    }

    var sections: Int {
        return 1
    }

    var hasConnections: Bool {
        return ConnectionsCollector.activeConnections.count > 0
    }

    var hasDataToShow: Bool {
        return viewModels.count > 0
    }

    var rows: Int {
        return viewModels.count
    }

    func viewModel(at index: Int) -> AuthorizationDetailViewModel? {
        guard viewModels.indices.contains(index) else { return nil }

        return viewModels[index]
    }

    func viewModel(by connectionId: String?, authorizationId: String?) -> AuthorizationDetailViewModel? {
        return viewModels.filter { $0.connectionId == connectionId && $0.authorizationId == authorizationId }.first
    }

    func index(of viewModel: AuthorizationDetailViewModel) -> Int? {
        return viewModels.firstIndex(of: viewModel)
    }

    func viewModel(with authorizationId: String, apiVersion: ApiVersion) -> AuthorizationDetailViewModel? {
        return viewModels.filter { $0.authorizationId == authorizationId && $0.apiVersion == apiVersion}.first
    }

    func confirmationData(for authorizationId: String, apiVersion: ApiVersion) -> SEConfirmAuthorizationRequestData? {
        guard let viewModel = viewModel(with: authorizationId, apiVersion: apiVersion),
            let connection = ConnectionsCollector.with(id: viewModel.connectionId),
            let url = connection.baseUrl else { return nil }

        return SEConfirmAuthorizationRequestData(
            url: url,
            connectionGuid: connection.guid,
            accessToken: connection.accessToken,
            appLanguage: UserDefaultsHelper.applicationLanguage,
            authorizationId: viewModel.authorizationId,
            authorizationCode: viewModel.authorizationCode,
            geolocation: LocationManager.currentLocation?.headerValue,
            authorizationType: PasscodeCoordinator.lastAppUnlockCompleteType.rawValue
        )
    }

    func clearAuthorizations() {
        viewModels.removeAll()
    }

    private func clearedViewModels() -> [AuthorizationDetailViewModel] {
        return self.viewModels.compactMap { viewModel in
            if viewModel.state.value != .base,
                let actionTime = viewModel.actionTime,
                Date().timeIntervalSince1970 - actionTime.timeIntervalSince1970 >= finalAuthorizationTimeToLive {
                return nil
            }
            if viewModel.expired,
                Date().timeIntervalSince1970 - viewModel.authorizationExpiresAt.timeIntervalSince1970
                    >= finalAuthorizationTimeToLive {
                return nil
            }
            return viewModel
        }
    }
}

private extension Array where Element == SEBaseAuthorizationData {
    func toAuthorizationViewModel(apiVersion: ApiVersion) -> [AuthorizationDetailViewModel] {
        return filter { $0.apiVersion == apiVersion }.compactMap { response in
            guard response.expiresAt >= Date() else { return nil }

            return AuthorizationDetailViewModel(response, apiVersion: response.apiVersion)
        }
    }
}

private extension Array where Element == AuthorizationDetailViewModel {
    func merge(array: [Element]) -> [AuthorizationDetailViewModel] {
        let finalElements: [Element] = array.filter { element in
            return element.expired || element.state.value != .base
        }

        let newAuthIds: [String] = self.map { $0.authorizationId }
        let newConnectionIds: [String] = self.map { $0.connectionId }

        var merged: [Element] = self
        merged.append(
            contentsOf: finalElements.filter {
                !newAuthIds.contains($0.authorizationId) ||
                !newConnectionIds.contains($0.connectionId)
            }
        )

        return merged
    }
}
