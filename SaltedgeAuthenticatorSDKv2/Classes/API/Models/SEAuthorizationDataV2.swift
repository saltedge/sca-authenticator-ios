//
//  SEAuthorizationDataV2
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2021 Salt Edge Inc.
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
import SEAuthenticatorCore

public class SEAuthorizationDataV2: SEBaseAuthorizationData {
    public let title: String
    public let description: [String: Any]
    public var createdAt: Date
    public var expiresAt: Date
    public var authorizationCode: String?

    public var id: String
    public var connectionId: String
    public var status: String

    public var apiVersion: ApiVersion = "2"

    public init?(_ dictionary: [String: Any], id: String, connectionId: String, status: String) {
        if let title = dictionary[SENetKeys.title] as? String,
           let description = dictionary[SENetKeys.description] as? [String: Any],
           let createdAt = (dictionary[SENetKeys.createdAt] as? String)?.iso8601date,
           let expiresAt = (dictionary[SENetKeys.expiresAt] as? String)?.iso8601date,
           let authorizationCode = dictionary[SENetKeys.authorizationCode] as? String {
            self.authorizationCode = authorizationCode
            self.title = title
            self.description = description
            self.createdAt = createdAt
            self.expiresAt = expiresAt
            self.id = id
            self.connectionId = connectionId
            self.status = status
        } else {
            return nil
        }
    }
}

extension SEAuthorizationDataV2: Equatable {
    public static func == (lhs: SEAuthorizationDataV2, rhs: SEAuthorizationDataV2) -> Bool {
        return lhs.title == rhs.title &&
            lhs.description == rhs.description &&
            lhs.createdAt == rhs.createdAt &&
            lhs.expiresAt == rhs.expiresAt &&
            lhs.authorizationCode == rhs.authorizationCode
    }
}

private func ==(lhs: [String: Any], rhs: [String: Any] ) -> Bool {
    return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}
