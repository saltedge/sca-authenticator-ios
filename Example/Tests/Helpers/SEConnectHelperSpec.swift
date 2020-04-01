//
//  SEConnectHelperSpec
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

class SEConnectHelperSpec: BaseSpec {
    override func spec() {
        describe("SEConnectHelper.isValid") {
            it("should return true or false") {
                var expectUrl = URL(string: "authenticator://saltedge.com/connect")
                
                expect(SEConnectHelper.isValid(deepLinkUrl: expectUrl!)).to(beFalse())
                
                expectUrl = URL(
                    string: "authenticator://saltedge.com/connect?configuration=https://saltedge.com/configuration"
                )
                
                expect(SEConnectHelper.isValid(deepLinkUrl: expectUrl!)).to(beTrue())
                
                expectUrl = URL(
                    string: "authenticator://saltedge.com/connect?configuration=https://saltedge.com/configuration&connect_query=A12345678"
                )
                
                expect(SEConnectHelper.isValid(deepLinkUrl: expectUrl!)).to(beTrue())

                expectUrl = URL(
                    string: "authenticator://saltedge.com/action?action_uuid=123456&connect_url=https://connect.com"
                )
                
                expect(SEConnectHelper.isValid(deepLinkUrl: expectUrl!)).to(beTrue())

                expectUrl = URL(
                    string: "authenticator://saltedge.com/action?action_uuid=123456"
                )

                expect(SEConnectHelper.isValid(deepLinkUrl: expectUrl!)).to(beFalse())
            }
        }

        describe("actionGuid") {
            it("should return action_uuid param value or nil") {
                let expectUrl = URL(string: "authenticator://saltedge.com/action?action_uuid=123456")

                expect(SEConnectHelper.actionGuid(from: expectUrl!)).to(equal("123456"))
            }
        }

        describe("connectUrl") {
            it("should return connect_url param value or nil") {
                let expectUrl = URL(string: "authenticator://saltedge.com/action?connect_url=https://connect.com")

                expect(SEConnectHelper.connectUrl(from: expectUrl!)).to(equal(URL(string: "https://connect.com")))
            }
        }

        describe("returnTo") {
            it("should return return_to param value or nil") {
                let expectUrl = URL(string: "authenticator://saltedge.com/action?connect_url=https://connect.com&return_to=https://return.com")

                expect(SEConnectHelper.returnToUrl(from: expectUrl!)).to(equal(URL(string: "https://return.com")))
            }
        }
        
        describe("SEConnectHelper.сonfiguration") {
            it("should return configuration param value or nil") {
                var expectUrl = URL(string: "authenticator://saltedge.com/connect")
                let targetUrl = URL(string: "https://saltedge.com/configuration")
                
                expect(SEConnectHelper.сonfiguration(from: expectUrl!)).to(beNil())
                
                expectUrl = URL(
                    string: "authenticator://saltedge.com/connect?configuration=https://saltedge.com/configuration"
                )
                
                expect(SEConnectHelper.сonfiguration(from: expectUrl!)).to(equal(targetUrl))
                
                expectUrl = URL(
                    string: "authenticator://saltedge.com/connect?configuration=https://saltedge.com/configuration&connect_query=A12345678"
                )
                
                expect(SEConnectHelper.сonfiguration(from: expectUrl!)).to(equal(targetUrl))
            }
        }
        
        describe("SEConnectHelper.connectQuery") {
            it("should return connect_query param value or nil") {
                var expectUrl = URL(string: "authenticator://saltedge.com/connect")
                
                expect(SEConnectHelper.connectQuery(from: expectUrl!)).to(beNil())
                
                expectUrl = URL(
                    string: "authenticator://saltedge.com/connect?configuration=https://saltedge.com/configuration"
                )
                
                expect(SEConnectHelper.connectQuery(from: expectUrl!)).to(beNil())
                
                expectUrl = URL(
                    string: "authenticator://saltedge.com/connect?configuration=https://my_host.org/configuration&connect_query=1234567890"
                )
                
                expect(SEConnectHelper.connectQuery(from: expectUrl!)).to(equal("1234567890"))
            }
        }
    }
}
