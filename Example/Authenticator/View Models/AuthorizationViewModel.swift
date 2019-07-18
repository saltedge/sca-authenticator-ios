//
//  AuthorizationViewModel.swift
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

import Foundation
import SEAuthenticator

struct AuthorizationViewModel: Equatable {
    var title: String = ""
    var authorizationId: String
    var connectionId: String
    var description: String = ""
    var authorizationCode: String?
    var lifetime: Int = 0
    var authorizationExpiresAt: Date = Date()

    init?(_ data: SEDecryptedAuthorizationData) {
        guard data.expiresAt > Date() else { return nil }

        self.authorizationId = data.id
        self.connectionId = data.connectionId
        self.authorizationCode = data.authorizationCode
        self.title = data.title
        self.description = data.description
        self.authorizationExpiresAt = data.expiresAt
        self.lifetime = Int(data.expiresAt.timeIntervalSince(data.createdAt))
    }

    // NOTE: think about moving it from here
    init(connectionId: String, authorizationId: String) {
        self.connectionId = connectionId
        self.authorizationId = authorizationId
    }

    static func == (lhs: AuthorizationViewModel, rhs: AuthorizationViewModel) -> Bool {
        return lhs.title == rhs.title &&
            lhs.description == rhs.description
    }
}

extension AuthorizationViewModel {
    func toBaseAuthorizationData() -> SEAuthorizationData? {
        guard let connection = ConnectionsCollector.with(id: connectionId), let url = connection.baseUrl else { return nil }

        return SEAuthorizationData(
            url: url,
            connectionGuid: connection.guid,
            accessToken: connection.accessToken,
            appLanguage: UserDefaultsHelper.applicationLanguage,
            authorizationId: authorizationId
        )
    }
}
