//
//  SetupStepSpec.swift
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

class SetupStepSpec: BaseSpec {
    override func spec() {
        describe("title") {
            it("should return appropriate title for every setup step") {
                expect(SetupStep.createPasscode.title).to(equal(l10n(.secureApp)))
                expect(SetupStep.allowBiometricsUsage.title).to(equal(BiometricsPresenter.allowText))
                expect(SetupStep.allowNotifications.title).to(equal(l10n(.allowNotifications)))
                expect(SetupStep.signUpComplete.title).to(equal(""))
            }
        }

        describe("description") {
            it("should return appropriate description for every setup step") {
                expect(SetupStep.createPasscode.description).to(equal(l10n(.secureAppDescription)))
                expect(SetupStep.allowBiometricsUsage.description).to(equal(BiometricsPresenter.usageDescription))
                expect(SetupStep.allowNotifications.description).to(equal(l10n(.allowNotificationsDescription)))
                expect(SetupStep.signUpComplete.description).to(equal(""))
            }
        }
    }
}
