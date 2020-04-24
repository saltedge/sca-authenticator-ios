//
//  AuthorizationResponses.swift
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

public struct SEEncryptedDataResponse: SerializableResponse {
    public var data: SEEncryptedData

    public init?(_ value: Any) {
        if let response = (value as AnyObject)[SENetKeys.data] as? [String: Any],
            let data = SEEncryptedData(response) {
            self.data = data
        } else {
            return nil
        }
    }
}

public struct SEEncryptedListResponse: SerializableResponse {
    public var data: [SEEncryptedData] = []

    public init?(_ value: Any) {
        if let responses = (value as AnyObject)[SENetKeys.data] as? [[String: Any]] {
            self.data = responses.compactMap { SEEncryptedData($0) }
        } else {
            return nil
        }
    }
}

public struct SEConfirmAuthorizationResponse: SerializableResponse {
    public let id: String
    public let success: Bool

    public init?(_ value: Any) {
        if let dict = value as? [String: Any],
            let data = dict[SENetKeys.data] as? [String: Any],
            let success = data[SENetKeys.success] as? Bool,
            let id = data[SENetKeys.id] as? String {
            self.id = id
            self.success = success
        } else {
            return nil
        }
    }
}
