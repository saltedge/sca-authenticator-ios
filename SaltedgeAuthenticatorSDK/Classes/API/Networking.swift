//
//  Networking.swift
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

extension Networking {
    static func execute(_ request: Routable,
                        success: @escaping RequestSuccessBlock,
                        failure: @escaping FailureBlock) {
        let task = URLSessionManager.shared.dataTask(with: request.asURLRequest()) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { failure(error.localizedDescription) }
            } else {
                guard let response = response as? HTTPURLResponse else {
                    DispatchQueue.main.async { failure("Something went wrong") }
                    return
                }

                if (200...299).contains(response.statusCode) {
                    guard let jsonData = deserializedDictionary(from: data) else {
                        return DispatchQueue.main.async { failure("Something went wrong") }
                    }

                    DispatchQueue.main.async { success(jsonData) }
                } else {
                    guard let jsonData = deserializedDictionary(from: data) else {
                        return DispatchQueue.main.async {
                            failure("Request not successful. HTTP status code: \(response.statusCode), \(response.description)")
                        }
                    }

                    if jsonData[SENetKeys.errorMessage] as? String != nil,
                        let errorClass = jsonData[SENetKeys.errorClass] as? String {
                        DispatchQueue.main.async { failure(errorClass) }
                    } else {
                        failure("Request not successful. HTTP status code: \(response.statusCode), \(response.description)")
                    }
                }
            }
        }

        task.resume()
    }

    private static func deserializedDictionary(from data: Data?) -> [String: Any]? {
        guard let requestData = data,
            let jsonData = try? JSONSerialization.jsonObject(
                with: requestData,
                options: []
        ) as? [String: Any] else { return nil }

        return jsonData
    }
}
