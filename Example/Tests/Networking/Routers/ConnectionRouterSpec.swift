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
        let baseUrl = URL(string: "base.com")!
        let baseUrlPath = "/api/authenticator/v1/connections"
        
        describe("ConnectionRouter") {
            context("when it's .getConnectUrl") {
                it("should create a valid url request") {
                    let data = SEConnectionData(code: "code", tag: "guid")!

                    let expectedRequest = URLRequestBuilder.buildUrlRequest(
                        with: baseUrl,
                        method: HTTPMethod.post.rawValue,
                        headers: Headers.requestHeaders(with: "en"),
                        params: RequestParametersBuilder.parameters(for: data, pushToken: "push token"),
                        encoding: .json
                    )

                    let request = SEConnectionRouter.getConnectUrl(baseUrl, data, "push token", "en").asURLRequest()

                    expect(request).to(equal(expectedRequest))
                }
            }

            context("when it's .revoke") {
                it("should create a valid url request") {
                    let data = SERevokeConnectionData(id: "1", guid: "guid", token: "token")

                    let signature = SignatureHelper.signedPayload(
                        method: .delete,
                        urlString: baseUrl.appendingPathComponent(baseUrlPath).absoluteString,
                        guid: data.guid,
                        params: nil
                    )

                    let headers = Headers.signedRequestHeaders(
                        token: data.token,
                        signature: signature,
                        appLanguage: "en"
                    )

                    let expectedRequest = URLRequestBuilder.buildUrlRequest(
                        with: baseUrl.appendingPathComponent(baseUrlPath),
                        method: HTTPMethod.delete.rawValue,
                        headers: headers,
                        encoding: .json
                    )
                    
                    let request = SEConnectionRouter.revoke(baseUrl, data, "en").asURLRequest()
                    
                    expect(request).to(equal(expectedRequest))
                }
            }
        }
    }
}
