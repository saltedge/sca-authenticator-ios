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

public struct SEProviderResponseV2: SerializableResponse {
    public let name: String
    public var baseUrl: URL
    public let providerId: String
    public let apiVersion: String
    public var logoUrl: URL?
    public var supportEmail: String
    public var publicKey: String
    public let geolocationRequired: Bool?

    public init?(_ value: Any) {
        if let dict = value as? [String: Any],
           let dataDict = dict[SENetKeys.data] as? [String: Any],
           let id = dataDict[ApiConstants.providerId] as? String,
           let name = dataDict[ApiConstants.providerName] as? String,
           let scaServiceUrlString = dataDict[ApiConstants.scaServiceUrl] as? String,
           let apiVersion = dataDict[ApiConstants.apiVersion] as? String,
           let publicKey = dataDict[ApiConstants.providerPublicKey] as? String,
           let scaServiceUrl = URL(string: scaServiceUrlString) {
            if let logoUrlString = dataDict[ApiConstants.providerLogoUrl] as? String,
                let logoUrl = URL(string: logoUrlString) {
                self.logoUrl = logoUrl
            }
            self.supportEmail = (dataDict[ApiConstants.providerSupportEmail] as? String) ?? ""
            self.geolocationRequired = dataDict[SENetKeys.geolocationRequired] as? Bool

            self.providerId = id
            self.name = name
            self.baseUrl = scaServiceUrl
            self.apiVersion = apiVersion
            self.publicKey = publicKey
        } else {
            return nil
        }
    }
}
