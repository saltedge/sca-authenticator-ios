//
//  SEProviderResponseV2
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

public struct SEProviderResponseV2: Decodable {
    public let name: String
    public var baseUrl: URL
    public let providerId: String
    public let apiVersion: String
    public var logoUrl: URL?
    public var supportEmail: String
    public var publicKey: String
    public let geolocationRequired: Bool?

    enum CodingKeys: String, CodingKey {
        case data
    }

    enum DataCodingKeys: String, CodingKey {
        case name = "provider_name"
        case baseUrl = "sca_service_url"
        case logoUrl = "logo_url"
        case apiVersion = "api_version"
        case supportEmail = "provider_support_email"
        case providerId = "provider_id"
        case publicKey = "provider_public_key"
        case geolocationRequired = "geolocation_required"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dataContainer = try container.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .data)
        name = try dataContainer.decode(String.self, forKey: .name)
        baseUrl = try dataContainer.decode(URL.self, forKey: .baseUrl)
        logoUrl = try dataContainer.decodeIfPresent(URL.self, forKey: .logoUrl)
        apiVersion = try dataContainer.decode(String.self, forKey: .apiVersion)
        supportEmail = try dataContainer.decode(String.self, forKey: .supportEmail)
        let id = try dataContainer.decode(Int.self, forKey: .providerId)
        providerId = "\(id)"
        publicKey = try dataContainer.decode(String.self, forKey: .publicKey)
        geolocationRequired = try dataContainer.decodeIfPresent(Bool.self, forKey: .geolocationRequired)
    }
}
