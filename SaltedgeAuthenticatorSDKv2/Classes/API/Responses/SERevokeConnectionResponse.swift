//
//  SERevokeConnectionResponse
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

public struct SERevokeConnectionResponse: SerializableResponse {
    public let connectionId: String

    public init?(_ value: Any) {
        if let dict = value as? [String: Any],
            let dataDict = dict[SENetKeys.data] as? [String: Any],
            let connectionId = dataDict[SENetKeys.connectionId] as? Int {
            self.connectionId = "\(connectionId)"
        } else {
            return nil
        }
    }
}
