//
//  Networking
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

public struct HTTPService<T: Decodable> {
    public static func makeRequest(
        _ request: Routable,
        completion: SEHTTPResponse<T>,
        failure: @escaping SimpleFailureClosure
    ) {
        makeRequest(request.asURLRequest(), completion: completion, failure: failure)
    }

    private static func makeRequest(
        _ request: URLRequest,
        completion: SEHTTPResponse<T>,
        failure: @escaping SimpleFailureClosure
    ) {
//         NOTE: Uncomment this to debug request
//         let urlString = request.url?.absoluteString ?? ""
//         print("🚀 Running request: \(request.httpMethod ?? "") - \(urlString)")

        let task = URLSessionManager.shared.dataTask(with: request) { data, _, error in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategyFormatters = [DateUtils.dateFormatter, DateUtils.ymdDateFormatter]

            let (data, error) = handleResponse(from: data, error: error, decoder: decoder)

            guard let jsonData = data, error == nil else {
                DispatchQueue.main.async { failure(error!.localizedDescription) }
                return
            }

//            NOTE: Uncomment this to debug response data
//            print("Response: ", String(data: jsonData, encoding: .utf8))

            do {
                let model = try decoder.decode(T.self, from: jsonData)
                DispatchQueue.main.async { completion?(model) }
            } catch {
                DispatchQueue.main.async { failure(error.localizedDescription) }
            }
        }
        task.resume()
    }

    private static func handleResponse(from data: Data?, error: Error?, decoder: JSONDecoder) -> (Data?, Error?) {
        if let error = error { return (nil, error) }

        guard let jsonData = data else {
            // -1017 -- The connection cannot parse the server’s response.
            let error = NSError(
                domain: "",
                code: -1017,
                userInfo: [NSLocalizedDescriptionKey: "Data was not retrieved from request"]
            ) as Error
            return (nil, error)
        }

        return (jsonData, nil)
    }
}

private extension JSONDecoder {
    var dateDecodingStrategyFormatters: [DateFormatter]? {
        get {
            return nil
        }
        set {
            guard let formatters = newValue else { return }

            self.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)

                for formatter in formatters {
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                }

                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
            }
        }
    }
}

