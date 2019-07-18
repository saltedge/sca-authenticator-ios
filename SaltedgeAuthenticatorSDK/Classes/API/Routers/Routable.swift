//
//  Routable.swift
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

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum Encoding: String {
    case url
    case json
}

protocol Routable {
    var method: HTTPMethod { get }
    var encoding: Encoding { get }
    var url: URL { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
}

extension Routable {
    func asURLRequest() -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers

        guard let parameters = parameters else { return request }

        if encoding == .url {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            components?.queryItems = parameters.asUrlQueryItems()
            request.url = components?.url
        }

        if request.value(forHTTPHeaderField: HeadersKeys.contentType) == nil {
            request.setValue("application/json", forHTTPHeaderField: HeadersKeys.contentType)
        }

        request.httpBody = ParametersSerializer.createBody(parameters: parameters)

        return request
    }
}

private extension Dictionary {
    func asUrlQueryItems() -> [URLQueryItem] {
        return map { URLQueryItem(name: "\($0.0)", value: "\($0.1)") }
    }
}
