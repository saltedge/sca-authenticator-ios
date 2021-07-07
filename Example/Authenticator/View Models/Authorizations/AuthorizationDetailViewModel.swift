//
//  AuthorizationDetailViewModel.swift
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
import SEAuthenticatorV2
import SEAuthenticatorCore

protocol AuthorizationDetailEventsDelegate: class {
    func confirmPressed(_ authorizationId: String, apiVersion: ApiVersion)
    func denyPressed(_ authorizationId: String, apiVersion: ApiVersion)
    func authorizationExpired()
}

final class AuthorizationDetailViewModel: Equatable {
    var title: String = ""
    var authorizationId: String
    var connectionId: String
    var description: String = ""
    var status: String = ""
    var descriptionAttributes: [String: Any] = [:]
    var authorizationCode: String?
    var lifetime: Int = 0
    var authorizationExpiresAt: Date = Date()
    var createdAt: Date = Date()
    var actionTime: Date? // NOTE: Time from where destroy is calculated
    var expired: Bool {
        authorizationExpiresAt < Date()
    }
    var state = Observable<AuthorizationStateView.AuthorizationState>(.base)
    var apiVersion: ApiVersion

    weak var delegate: AuthorizationDetailEventsDelegate?

    init?(_ data: SEBaseAuthorizationData, apiVersion: ApiVersion) {
        if let dataV1 = data as? SEAuthorizationData {
            self.title = dataV1.title
            self.description = dataV1.description
        } else if let dataV2 = data as? SEAuthorizationDataV2 {
            self.title = dataV2.title
            self.descriptionAttributes = dataV2.description
            self.status = dataV2.status
        }
        self.apiVersion = apiVersion
        self.authorizationId = data.id
        self.connectionId = data.connectionId
        self.authorizationCode = data.authorizationCode
        self.authorizationExpiresAt = data.expiresAt
        self.lifetime = Int(data.expiresAt.timeIntervalSince(data.createdAt))
        self.createdAt = data.createdAt
        self.state.value = data.expiresAt < Date() ? .timeOut : .base
    }

    static func == (lhs: AuthorizationDetailViewModel, rhs: AuthorizationDetailViewModel) -> Bool {
        return lhs.authorizationId == rhs.authorizationId &&
            lhs.connectionId == rhs.connectionId &&
            lhs.title == rhs.title &&
            lhs.description == rhs.description &&
            lhs.createdAt == rhs.createdAt &&
            lhs.apiVersion == rhs.apiVersion
    }

    var authorizationExpired: Bool = false {
        didSet {
            if authorizationExpired {
                delegate?.authorizationExpired()
            }
        }
    }

    var shouldShowLocationWarning: Bool {
        guard let connection = ConnectionsCollector.active(by: connectionId) else { return false }

        return LocationManager.shared.shouldShowLocationWarning(connection: connection)
    }

    func confirmPressed() {
        delegate?.confirmPressed(authorizationId, apiVersion: apiVersion)
    }

    func denyPressed() {
        delegate?.denyPressed(authorizationId, apiVersion: apiVersion)
    }

    func setFinal(status: String) {
        guard status.isFinalStatus,
              let authStatus = AuthorizationStateView.AuthorizationState(rawValue: status) else { return }

        self.status = status
        self.state.value = authStatus
        self.actionTime = Date()
    }
}
