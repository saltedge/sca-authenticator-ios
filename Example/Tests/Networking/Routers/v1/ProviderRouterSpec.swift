//
//  ProviderRouterSpec.swift
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
import SEAuthenticatorCore
@testable import SEAuthenticator

class ProviderRouterSpec: BaseSpec {
    override func spec() {
        describe("ProviderRouter") {
            context("when it's .fetchData") {
                it("should create a valid url request") {
                    let baseUrl = URL(string: "fetchProvider.com")!

                    let expectedRequest = URLRequestBuilder.buildUrlRequest(
                        with: baseUrl,
                        method: HTTPMethod.get.rawValue,
                        headers: nil,
                        params: nil,
                        encoding: .url
                    )

                    let request = SEProviderRouter.fetchData(baseUrl).asURLRequest()

                    expect(request).to(equal(expectedRequest))
                }
            }
        }
    }
}
