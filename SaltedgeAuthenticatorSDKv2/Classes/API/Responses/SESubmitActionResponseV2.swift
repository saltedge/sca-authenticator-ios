//
//  SESubmitActionResponseV2
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

public struct SESubmitActionResponseV2: SEBaseActionResponse {
    public var authorizationId: String?
    public var connectionId: String?

    enum CodingKeys: String, CodingKey {
        case data
    }

    enum DataCodingKeys: String, CodingKey {
        case authorizationId = "authorization_id"
        case connectionId = "connection_id"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dataContainer = try container.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .data)
        if let authorizationV2Id = try dataContainer.decodeIfPresent(Int.self, forKey: .authorizationId) {
            authorizationId = "\(authorizationV2Id)"
        }
        if let connectionV2Id = try dataContainer.decodeIfPresent(Int.self, forKey: .connectionId) {
            connectionId = "\(connectionV2Id)"
        }
    }
}
