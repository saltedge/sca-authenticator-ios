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

final class AuthorizationsDataSource {
    private var authorizationResponses = [SEDecryptedAuthorizationData]()
    private var viewModels = [AuthorizationViewModel]()

    func update(with authorizationResponses: [SEDecryptedAuthorizationData]) -> Bool {
        if authorizationResponses != self.authorizationResponses {
            self.authorizationResponses = authorizationResponses
            self.viewModels = authorizationResponses.compactMap { response in
                guard response.expiresAt >= Date() else { return nil }

                return AuthorizationViewModel(response)
            }.merge(array: self.viewModels).sorted(by: { $0.createdAt < $1.createdAt })
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

    var hasDataToShow: Bool {
        return viewModels.count > 0
    }

    var rows: Int {
        return viewModels.count
    }

    func viewModel(at index: Int) -> AuthorizationViewModel? {
        guard viewModels.indices.contains(index) else { return nil }

        return viewModels[index]
    }

    func viewModel(by connectionId: String?, authorizationId: String?) -> AuthorizationViewModel? {
        return viewModels.filter { $0.connectionId == connectionId && $0.authorizationId == authorizationId }.first
    }

    func index(of viewModel: AuthorizationViewModel) -> Int? {
        return viewModels.firstIndex(of: viewModel)
    }

    func viewModel(with authorizationId: String) -> AuthorizationViewModel? {
        return viewModels.filter({ $0.authorizationId == authorizationId }).first
    }

    func confirmationData(for authorizationId: String) -> SEConfirmAuthorizationData? {
        guard let viewModel = viewModel(with: authorizationId),
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

    func clearAuthorizations() {
        authorizationResponses.removeAll()
        viewModels.removeAll()
    }

    private func clearedViewModels() -> [AuthorizationViewModel] {
        return self.viewModels.compactMap { viewModel in
            if viewModel.state != .base,
                let actionTime = viewModel.actionTime, Date().timeIntervalSince1970 - actionTime.timeIntervalSince1970 >= 3 {
                return nil
            }
            if viewModel.expired, Date().timeIntervalSince1970 - viewModel.authorizationExpiresAt.timeIntervalSince1970 >= 3 {
                return nil
            }
            return viewModel
        }
    }
}

extension Array where Element == AuthorizationViewModel {
    func merge(array: [Element]) -> [AuthorizationViewModel] {
        let expiredElements: [Element] = array.compactMap { element in
            if element.expired || element.state != .base {
                return element
            } else {
                return nil
            }
        }

        let newAuthIds: [String] = self.map { $0.authorizationId }
        let newConnectionIds: [String] = self.map { $0.connectionId }

        var merged: [Element] = self
        merged.append(contentsOf: expiredElements
            .filter { !newAuthIds.contains($0.authorizationId) || !newConnectionIds.contains($0.connectionId) }
        )

        return merged
    }
}
