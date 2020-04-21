//
//  SEConsentData
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

public struct SEConsentData {
    public let id: String
    public let connectionId: String
    public let title: String
    public let description: String
    public let createdAt: Date
    public let expiresAt: Date

    public init?(_ dictionary: [String: Any]) {
        if let id = dictionary[SENetKeys.id] as? String,
            let connectionId = dictionary[SENetKeys.connectionId] as? String,
            let title = dictionary[SENetKeys.title] as? String,
            let description = dictionary[SENetKeys.description] as? String,
            let createdAt = (dictionary[SENetKeys.createdAt] as? String)?.iso8601date,
            let expiresAt = (dictionary[SENetKeys.expiresAt] as? String)?.iso8601date {
            self.id = id
            self.connectionId = connectionId
            self.title = title
            self.description = description
            self.createdAt = createdAt
            self.expiresAt = expiresAt
        } else {
            return nil
        }
    }
}

extension SEConsentData: Equatable {
    public static func == (lhs: SEConsentData, rhs: SEConsentData) -> Bool {
        return lhs.id == rhs.id &&
            lhs.connectionId == rhs.connectionId &&
            lhs.title == rhs.title &&
            lhs.description == rhs.description &&
            lhs.createdAt == rhs.createdAt &&
            lhs.expiresAt == rhs.expiresAt
    }
}
