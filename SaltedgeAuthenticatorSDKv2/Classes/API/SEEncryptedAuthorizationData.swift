//
//  SEEncryptedAuthorizationData
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

public struct SEEncryptedAuthorizationData: SEBaseEncryptedAuthorizationData, SerializableResponse {
    public let id: String
    public let data: String
    public let key: String
    public let iv: String
    public let status: String
    public var connectionId: String?

    public init?(_ value: Any) {
        if let dict = value as? [String: Any],
            let id = dict[SENetKeys.id] as? Int,
            let data = dict[SENetKeys.data] as? String,
            let key = dict[SENetKeys.key] as? String,
            let iv = dict[SENetKeys.iv] as? String,
            let status = dict[SENetKeys.status] as? String,
            let connectionId = dict[SENetKeys.connectionId] as? Int {
            self.id = "\(id)"
            self.data = data
            self.key = key
            self.iv = iv
            self.status = status
            self.connectionId = "\(connectionId)"
        } else {
            return nil
        }
    }
}
