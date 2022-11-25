//
//  ApiVersionExtractorSpec
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

import Quick
import Nimble
@testable import SEAuthenticatorCore

class ApiVersionExtractorSpec: BaseSpec {
    override func spec() {
        describe("apiVersion") {
            context("when url contains version") {
                it("should return correct version from given url") {
                    let urlString = "https://sca.banksalt.com/api/authenticator/v2/configurations/1"
                    
                    expect(urlString.apiVerion).to(equal("2"))
                }
            }

            context("when url doesn't contain version") {
                it("should return default value 1") {
                    let urlString = "https://sca.banksalt.com/api/authenticator/configurations/1"
                    
                    expect(urlString.apiVerion).to(equal("1"))
                }
            }
        }
    }
}
