//
//  HeadersSpec.swift
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

class HeadersSpec: BaseSpec {
    override func spec() {
        let defaultRequestHeaders: [String: String] = [
            "Accept": "application/json",
            "Accept-Language": "en",
            "Content-Type": "application/json"
        ]

        let expiresAt = Date().addingTimeInterval(5.0 * 60.0).utcSeconds

        describe("authorizedRequestHeaders(token:)") {
            it("should return apropriate headers with AccessToken") {
                let token = "some token"
                let expectedHeaders = defaultRequestHeaders.merge(with: ["Access-Token": token])

                let isEqual = Headers.authorizedRequestHeaders(token: token, appLanguage: "en") == expectedHeaders
                expect(isEqual).to(beTruthy())
            }
        }

        describe("signedRequestHeaders(token:..)") {
            context("when signature exists") {
                it("should return apropriate signed headers") {
                    let token = "token"
                    let signature = "some signature"

                    let expectedHeaders = Headers.authorizedRequestHeaders(token: token, appLanguage: "en").merge(
                        with: [HeadersKeys.expiresAt: "\(expiresAt)", HeadersKeys.signature: "\(signature)"]
                    )

                    expect(expectedHeaders).to(
                        equal(Headers.signedRequestHeaders(token: token, expiresAt: expiresAt, signature: signature, appLanguage: "en"))
                    )
                }
            }

            context("when signature doesn't exist") {
                it("should return authorizedRequestHeaders") {
                    let token = "token"

                    let expectedHeaders = Headers.authorizedRequestHeaders(token: token, appLanguage: "en")

                    expect(expectedHeaders).to(
                        equal(Headers.signedRequestHeaders(token: token, expiresAt: expiresAt, signature: nil, appLanguage: "en"))
                    )
                }
            }
        }
    }
}
