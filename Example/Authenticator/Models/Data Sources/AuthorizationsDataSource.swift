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
    private var authorizationResponses = [SEEncryptedAuthorizationResponse]()
    private var viewModels = [AuthorizationViewModel]()

    func update(with authorizationResponses: [SEEncryptedAuthorizationResponse]) -> Bool {
        if authorizationResponses != self.authorizationResponses {
            self.authorizationResponses = authorizationResponses
            self.viewModels = authorizationResponses.compactMap { response in
                guard let data = AuthorizationsPresenter.decryptedData(from: response) else { return nil }

                return AuthorizationViewModel(data)
            }
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

    func rows() -> Int {
        return viewModels.count
    }

    func remove(_ viewModel: AuthorizationViewModel) -> Int? {
        guard let index = viewModels.firstIndex(of: viewModel) else { return nil }

        viewModels.remove(at: index)

        if authorizationResponses.indices.contains(index) { authorizationResponses.remove(at: index) }

        return index
    }

    func viewModel(at index: Int) -> AuthorizationViewModel? {
        guard viewModels.indices.contains(index) else { return nil }

        return viewModels[index]
    }

//    func cell(tableView: UITableView, for indexPath: IndexPath) -> AuthorizationCell {
//        let cell: AuthorizationCell = tableView.dequeueReusableCell(for: indexPath)
//        cell.set(with: viewModels[indexPath.section])
//        return cell
//    }
}
