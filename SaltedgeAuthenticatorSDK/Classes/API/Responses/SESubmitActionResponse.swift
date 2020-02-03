//
//  SESubmitActionResponse
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

public struct SESubmitActionResponse: SerializableResponse {
    public let success: Bool
    public var authorizationId: String?
    public var connectionId: String?

    public init?(_ value: Any) {
        if let dict = value as? [String: Any],
            let data = dict[SENetKeys.data] as? [String: Any],
            let success = data[SENetKeys.success] as? Bool {
            if let authorizationId = data[SENetKeys.authorizationId] as? String {
                self.authorizationId = authorizationId
            }
            if let connectionId = data[SENetKeys.connectionId] as? String {
                self.connectionId = connectionId
            }
            self.success = success
        } else {
            return nil
        }
    }
}
