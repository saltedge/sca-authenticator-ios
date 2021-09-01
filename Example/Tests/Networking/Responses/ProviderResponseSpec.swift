//
//  ProviderResponseSpec.swift
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
@testable import SEAuthenticatorCore

class ProviderResponseSpec: BaseSpec {
    override func spec() {
        describe("init?(value:)") {
            context("when the value is a proper dictionary containing the necessary data") {
                it("should create correct response") {
                    let fixture = DataFixtures.validProviderResponse
                    let response = SpecDecodableModel<SEProviderResponse>.create(from: fixture)
                    
                    expect(response).toNot(beNil())
                    expect(response.code).to(equal("demobank"))
                    expect(response.baseUrl.absoluteString).to(equal("getConnectUrl.com"))
                    expect(response.name).to(equal("Demobank"))
                    expect(response.logoUrl?.absoluteString).to(equal("https://upload.wikimedia.org/wikipedia/commons/6/6f/HP_logo_630x630.png"))
                    expect(response.version).to(equal("1"))
                }
            }

            context("when the value is a malformed dictionary or is missing data") {
                it("should return nil and fail to initialize the object") {
                    let fixture = DataFixtures.invalidProviderResponse
                    let response = SpecDecodableModel<SEProviderResponse>.create(from: fixture)

                    expect(response).to(beNil())
                }
            }
        }
    }
}
