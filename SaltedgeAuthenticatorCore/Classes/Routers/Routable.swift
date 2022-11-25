//
//  Routable.swift
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

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum Encoding: String {
    case url
    case json
}

public protocol Routable {
    var method: HTTPMethod { get }
    var encoding: Encoding { get }
    var url: URL { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
}

public extension Routable {
    func asURLRequest() -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.setValue(userAgentValue, forHTTPHeaderField: "User-Agent")

        guard let parameters = parameters else { return request }

        if encoding == .url {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            components?.queryItems = parameters.asUrlQueryItems()
            request.url = components?.url
        }

        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        request.httpBody = ParametersSerializer.createBody(parameters: parameters)

        return request
    }

    /*
      Build application and device info:
      e.g.: Authenticator / 3.3.0(130); (iPhone 8 Plus; iOS 14.5)
    */
    private var userAgentValue: String {
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""

        return "\(appName) / \(version)(\(buildNumber)); "
            + "(\(UIDevice().type.rawValue); \(UIDevice.current.systemName) \(UIDevice.current.systemVersion))"
    }
}

private extension Dictionary {
    func asUrlQueryItems() -> [URLQueryItem] {
        return map { URLQueryItem(name: "\($0.0)", value: "\($0.1)") }
    }
}
