//
//  PasscodeViewModelSpec
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

final class PasscodeViewModelSpec: BaseSpec {
    override func spec() {
        describe("wrong passcode") {
            it("should set view model state to .wrongPasscode") {
                let viewModel = PasscodeViewModel(purpose: .edit)

                expect(viewModel.state.value).to(equal(PasscodeViewModelState.normal))

                viewModel.wrongPasscode()

                expect(viewModel.state.value).to(equal(PasscodeViewModelState.wrongPasscode))
            }
        }

        describe("switchToCreate") {
            it("should set view model state to .switchToCreate") {
                let viewModel = PasscodeViewModel(purpose: .edit)

                expect(viewModel.state.value).to(equal(PasscodeViewModelState.normal))

                viewModel.switchToCreate()

                expect(viewModel.state.value).to(equal(PasscodeViewModelState.switchToCreate))
            }
        }

        describe("stageCompleted") {
//            context("when purpose is create and it's first stage") {
//                it("should switch to repeat") {
//                    let viewModel = PasscodeViewModel(purpose: .create)
//
//                    expect(viewModel.state.value).to(equal(PasscodeViewModelState.normal))
//
//                    viewModel.stageCompleted()
//
//                    expect(viewModel.state.value).to(equal(PasscodeViewModelState.repeat))
//                }
//            }

            context("when purpose is create and it's second stage") {
                it("should compare passwords") {
                    let viewModel = PasscodeViewModel(purpose: .create)

                    expect(viewModel.state.value).to(equal(PasscodeViewModelState.normal))

                    viewModel.switchToRepeat()
                    viewModel.stageCompleted()
                }
            }
        }
    }
}
