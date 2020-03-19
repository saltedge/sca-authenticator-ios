//
//  DecryptedAuthorizationDataSpec.swift
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

class DecryptedAuthorizationDataSpec: BaseSpec {
    override func spec() {
        describe("init?(_ dictionary:)") {
            context("when given dict contains all required parameters") {
                it("should initialize data from given dictionary") {
                    let authMessage = ["id": "00000",
                                       "connection_id": "12345",
                                       "title": "Authorization",
                                       "description": "Test authorization",
                                       "created_at": "2019-05-20T09:30:40Z",
                                       "expires_at": "2019-05-20T09:30:45Z",
                                       "authorization_code": "11"]
                    let expectedData = SEDecryptedAuthorizationData(authMessage)!
                    
                    expect(expectedData.id).to(equal("00000"))
                    expect(expectedData.connectionId).to(equal("12345"))
                    expect(expectedData.title).to(equal("Authorization"))
                    expect(expectedData.description).to(equal("Test authorization"))
                    expect(expectedData.createdAt.iso8601string).to(equal("2019-05-20T09:30:40Z"))
                    expect(expectedData.expiresAt.iso8601string).to(equal("2019-05-20T09:30:45Z"))
                    expect(expectedData.authorizationCode).to(equal("11"))
                }
            }

            context("when given dict isn't correct") {
                it("should be nil") {
                    let authMessage = ["id": "00000",
                                       "title": "Authorization",
                                       "description": "Test authorization",
                                       "created_at": "2019-05-20T09:30:40Z",
                                       "expires_at": "2019-05-20T09:30:45.378Z"]
                    let expectedData = SEDecryptedAuthorizationData(authMessage)

                    expect(expectedData).to(beNil())
                }
            }
        }
    }
}
