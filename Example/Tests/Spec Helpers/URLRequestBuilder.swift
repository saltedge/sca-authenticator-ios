//
//  URLRequestBuilder.swift
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
@testable import SEAuthenticator

struct URLRequestBuilder {
    static func buildUrlRequest(
        with url: URL,
        method: String,
        headers: [String: String]? = nil,
        params: [String: Any]? = nil,
        encoding: Encoding = .json
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers

        if encoding == .url {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            components?.queryItems = params?.map { URLQueryItem(name: "\($0.0)", value: "\($0.1)") }
            request.url = components?.url
        }

        guard let parameters = params else { return request }

        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)

            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }

            request.httpBody = data
        } catch {
            print(error.localizedDescription)
        }
        return request
    }
}
