//
//  CreateConnectionResponseSpec.swift
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

class CreateConnectionResponseSpec: BaseSpec {
    override func spec() {
        describe("init?(value:)") {
            context("when the value is a proper dictionary containing the necessary data") {
                it("should create correct response") {
                    let fixture = DataFixtures.validCreateConnectionData
                    let expectedResponse = SECreateConnectionResponse(fixture)

                    expect(expectedResponse).toNot(beNil())
                    expect(expectedResponse?.connectUrl).to(equal("connect.com"))
                    expect(expectedResponse?.id).to(equal("123456789"))
                }
            }

            context("when the value is a malformed dictionary or is missing data") {
                it("should return nil and fail to initialize the object") {
                    let fixture = DataFixtures.invalidCreateConnectionData
                    let response = SECreateConnectionResponse(fixture)
                    
                    expect(response).to(beNil())
                }
            }
        }
    }
}
