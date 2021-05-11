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

public struct SEProviderResponse: SerializableResponse {
    public let name: String
    public let code: String
    public let connectUrl: URL
    public let version: String
    public var logoUrl: URL?
    public var supportEmail: String
    public let geolocationRequired: Bool?

    public init?(_ value: Any) {
        if let dict = value as? [String: Any],
            let data = dict[SENetKeys.data] as? [String: Any],
            let name = data[SENetKeys.name] as? String,
            let code = data[SENetKeys.code] as? String,
            let connectUrlString = data[SENetKeys.connectUrl] as? String,
            let version = data[SENetKeys.version] as? String,
            let connectUrl = URL(string: connectUrlString) {

            if let logoUrlString = data[SENetKeys.logoUrl] as? String,
                let logoUrl = URL(string: logoUrlString) {
                self.logoUrl = logoUrl
            }
            geolocationRequired = data[SENetKeys.geolocationRequired] as? Bool
            self.supportEmail = (data[SENetKeys.supportEmail] as? String) ?? ""
            self.name = name
            self.code = code
            self.connectUrl = connectUrl
            self.version = version
        } else {
            return nil
        }
    }
}
