//
//  Headers.swift
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

struct HeadersKeys {
    static let accessToken = "Access-Token"
    static let accept = "Accept"
    static let acceptLanguage = "Accept-Language"
    static let contentType = "Content-Type"
    static let expiresAt = "Expires-At"
    static let signature = "Signature"
    static let geolocation = "GEO-Location"
}

struct Headers {
    static func signedRequestHeaders(token: String, expiresAt: Int, signature: String?, appLanguage: String) -> [String: String] {
        guard let signedMessage = signature else { return authorizedRequestHeaders(token: token, appLanguage: appLanguage) }

        return authorizedRequestHeaders(token: token, appLanguage: appLanguage).merge(
            with: [
                HeadersKeys.expiresAt: "\(expiresAt)",
                HeadersKeys.signature: "\(signedMessage)"
            ]
        )
    }

    static func authorizedRequestHeaders(token: String, appLanguage: String) -> [String: String] {
        return requestHeaders(with: appLanguage).merge(with: [HeadersKeys.accessToken: token])
    }

    static func requestHeaders(with appLanguage: String) -> [String: String] {
        return [
            HeadersKeys.accept: "application/json",
            HeadersKeys.acceptLanguage: appLanguage,
            HeadersKeys.contentType: "application/json"
        ]
    }
}

extension Dictionary where Key == String, Value == String {
    func addLocationHeader(geolocation: String?) -> [String: String] {
        guard let geolocation = geolocation else { return self }

        return self.merge(with: [ HeadersKeys.geolocation: geolocation ])
    }

}
