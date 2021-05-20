//
//  ActionRouterSpec
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2020 Salt Edge Inc.
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
import SEAuthenticatorCore
@testable import SEAuthenticator

class ActionRouterSpec: BaseSpec {
    override func spec() {
        let baseUrl = URL(string: "base.com")!
        let baseUrlPath = "api/authenticator/v1/actions"
        let actionGuid = "123"
        let expiresAt = Date().addingTimeInterval(5.0 * 60.0).utcSeconds
        
        describe("ActionRouter") {
            it("should create a valid url request") {
                let signature = SignatureHelper.signedPayload(
                    method: .put,
                    urlString: baseUrl.appendingPathComponent("\(baseUrlPath)/\(actionGuid)").absoluteString,
                    guid: "tag",
                    expiresAt: expiresAt,
                    params: nil
                )

                let headers = Headers.signedRequestHeaders(
                    token: "token",
                    expiresAt: expiresAt,
                    signature: signature,
                    appLanguage: "en"
                )

                let expectedRequest = URLRequestBuilder.buildUrlRequest(
                    with: baseUrl.appendingPathComponent("\(baseUrlPath)/\(actionGuid)"),
                    method: HTTPMethod.put.rawValue,
                    headers: headers,
                    encoding: .json
                )

                let expectedActionData = SEActionRequestData(
                    url: baseUrl,
                    connectionGuid: "tag",
                    accessToken: "token",
                    appLanguage: "en",
                    guid: actionGuid
                )

                let request = SEActionRouter.submit(expectedActionData).asURLRequest()

                expect(request).to(equal(expectedRequest))
            }
        }
    }
}

