//
//  ConnectionRouterSpec.swift
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

import Quick
import Nimble
@testable import SEAuthenticator

class ConnectionRouterSpec: BaseSpec {
    override func spec() {
        let baseUrl = URL(string: "https://ad.int.example.com:4567/56278094067945dc9a60742a35c9f3f3")!
        let baseUrlPath = "/api/authenticator/v1/connections"
        
        describe("ConnectionRouter") {
            context("when it's .createConnection") {
                it("should create a valid url request") {
                    let data = SECreateConnectionRequestData(code: "code", tag: "guid")!

                    let expectedRequest = URLRequestBuilder.buildUrlRequest(
                        with: baseUrl,
                        method: HTTPMethod.post.rawValue,
                        headers: Headers.requestHeaders(with: "en"),
                        params: RequestParametersBuilder.parameters(
                            for: data,
                            pushToken: "push token",
                            connectQuery: nil
                        ),
                        encoding: .json
                    )

                    let request = SEConnectionRouter.createConnection(
                        baseUrl,
                        data,
                        "push token",
                        nil,
                        "en"
                    ).asURLRequest()

                    expect(request).to(equal(expectedRequest))
                }
            }

            context("when it's .revoke") {
                it("should create a valid url request") {
                    let data = SEBaseAuthenticatedWithIdRequestData(
                        url: baseUrl,
                        connectionGuid: "guid",
                        accessToken: "token",
                        appLanguage: "en",
                        entityId: "1"
                    )

                    let expiresAt = Date().addingTimeInterval(5.0 * 60.0).utcSeconds

                    let signature = SignatureHelper.signedPayload(
                        method: .delete,
                        urlString: baseUrl.appendingPathComponent(baseUrlPath).absoluteString,
                        guid: data.connectionGuid,
                        expiresAt: expiresAt,
                        params: nil
                    )

                    let headers = Headers.signedRequestHeaders(
                        token: data.accessToken,
                        expiresAt: expiresAt,
                        signature: signature,
                        appLanguage: "en"
                    )

                    let expectedRequest = URLRequestBuilder.buildUrlRequest(
                        with: baseUrl.appendingPathComponent(baseUrlPath),
                        method: HTTPMethod.delete.rawValue,
                        headers: headers,
                        encoding: .json
                    )
                    
                    let request = SEConnectionRouter.revoke(data).asURLRequest()
                    
                    expect(request).to(equal(expectedRequest))
                }
            }
        }
    }
}
