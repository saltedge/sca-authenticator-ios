//
//  SEProviderResponse.swift
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
import SEAuthenticatorCore

public struct SEProviderResponse: Decodable {
    public var baseUrl: URL
    public let name: String
    public let code: String
    public var version: String
    public var logoUrl: URL?
    public var supportEmail: String
    public let geolocationRequired: Bool?

    enum CodingKeys: String, CodingKey {
        case data
    }

    enum DataCodingKeys: String, CodingKey {
        case name
        case code
        case baseUrl = "connect_url"
        case logoUrl = "logo_url"
        case version
        case supportEmail = "support_email"
        case geolocationRequired = "geolocation_required"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dataContainer = try container.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .data)
        name = try dataContainer.decode(String.self, forKey: .name)
        code = try dataContainer.decode(String.self, forKey: .code)
        baseUrl = try dataContainer.decode(URL.self, forKey: .baseUrl)
        logoUrl = try dataContainer.decodeIfPresent(URL.self, forKey: .logoUrl)
        version = try dataContainer.decode(String.self, forKey: .version)
        supportEmail = try dataContainer.decode(String.self, forKey: .supportEmail)
        version = try dataContainer.decode(String.self, forKey: .version)
        geolocationRequired = try dataContainer.decodeIfPresent(Bool.self, forKey: .geolocationRequired)
    }
}
