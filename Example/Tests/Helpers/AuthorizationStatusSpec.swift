//
//  AuthorizationStatusSpec
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

final class AuthorizationStatusSpec: BaseSpec {
    override func spec() {
        var authorizationStatus: AuthorizationStatus!

        describe("isClosed") {
            it("should return true if authorization status is closed") {
                authorizationStatus = .closed

                expect(authorizationStatus.isClosed).to(equal(true))
            }

            it("should return false if authorization status is closed") {
                authorizationStatus = .pending

                expect(authorizationStatus.isClosed).to(equal(false))

                authorizationStatus = .processing

                expect(authorizationStatus.isClosed).to(equal(false))

                authorizationStatus = .confirmed

                expect(authorizationStatus.isClosed).to(equal(false))

                authorizationStatus = .denied

                expect(authorizationStatus.isClosed).to(equal(false))

                authorizationStatus = .error

                expect(authorizationStatus.isClosed).to(equal(false))

                authorizationStatus = .timeOut

                expect(authorizationStatus.isClosed).to(equal(false))

                authorizationStatus = .unavailable

                expect(authorizationStatus.isClosed).to(equal(false))

                authorizationStatus = .confirmProcessing

                expect(authorizationStatus.isClosed).to(equal(false))

                authorizationStatus = .denyProcessing

                expect(authorizationStatus.isClosed).to(equal(false))
            }
        }

        describe("isProcessing") {
            it("should return true if authorization status is processing") {
                authorizationStatus = .confirmProcessing

                expect(authorizationStatus.isProcessing).to(equal(true))

                authorizationStatus = .denyProcessing

                expect(authorizationStatus.isProcessing).to(equal(true))
            }

            it("should return false if authorization status is processing") {
                authorizationStatus = .pending

                expect(authorizationStatus.isProcessing).to(equal(false))

                authorizationStatus = .processing

                expect(authorizationStatus.isProcessing).to(equal(false))

                authorizationStatus = .confirmed

                expect(authorizationStatus.isProcessing).to(equal(false))

                authorizationStatus = .denied

                expect(authorizationStatus.isProcessing).to(equal(false))

                authorizationStatus = .error

                expect(authorizationStatus.isProcessing).to(equal(false))

                authorizationStatus = .timeOut

                expect(authorizationStatus.isProcessing).to(equal(false))

                authorizationStatus = .unavailable

                expect(authorizationStatus.isProcessing).to(equal(false))

                authorizationStatus = .closed

                expect(authorizationStatus.isProcessing).to(equal(false))
            }
        }

        describe("isFinal") {
            it("should return true if authorization status is final") {
                authorizationStatus = .confirmed

                expect(authorizationStatus.isFinal).to(equal(true))

                authorizationStatus = .denied

                expect(authorizationStatus.isFinal).to(equal(true))

                authorizationStatus = .error

                expect(authorizationStatus.isFinal).to(equal(true))

                authorizationStatus = .timeOut

                expect(authorizationStatus.isFinal).to(equal(true))

                authorizationStatus = .unavailable

                expect(authorizationStatus.isFinal).to(equal(true))
            }

            it("should return false if authorization status is final") {
                authorizationStatus = .pending

                expect(authorizationStatus.isFinal).to(equal(false))

                authorizationStatus = .processing

                expect(authorizationStatus.isFinal).to(equal(false))

                authorizationStatus = .confirmProcessing

                expect(authorizationStatus.isFinal).to(equal(false))

                authorizationStatus = .denyProcessing

                expect(authorizationStatus.isFinal).to(equal(false))

                authorizationStatus = .closed

                expect(authorizationStatus.isFinal).to(equal(false))
            }
        }
    }
}
