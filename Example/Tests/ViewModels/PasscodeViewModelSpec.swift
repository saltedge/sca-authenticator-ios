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
        beforeEach {
            KeychainHelper.deleteObject(forKey: KeychainKeys.passcode.rawValue)
        }

        describe("title") {
            it("should return correct text depending on purpose") {
                expect(PasscodeViewModel(purpose: .create).title).to(equal(l10n(.createPasscode)))
                expect(PasscodeViewModel(purpose: .edit).title).to(equal(l10n(.yourCurrentPasscode)))
                expect(PasscodeViewModel(purpose: .enter).title).to(equal(""))
            }
        }

        describe("wrongPasscodeLabelText") {
            it("should return correct text depending on purpose") {
                expect(PasscodeViewModel(purpose: .create).wrongPasscodeLabelText).to(equal(l10n(.passcodeDontMatch)))
                expect(PasscodeViewModel(purpose: .edit).wrongPasscodeLabelText).to(equal(l10n(.passcodeDontMatch)))
                expect(PasscodeViewModel(purpose: .enter).wrongPasscodeLabelText).to(equal(l10n(.wrongPasscode)))
            }
        }

        describe("didInput(digit:, symbols:)") {
            context("when entered passcode contains less than 3 digits") {
                it("should append to passcode") {
                    let viewModel = PasscodeViewModel(purpose: .create)

                    expect(viewModel.passcodeToFill).to(beEmpty())

                    viewModel.didInput(
                        digit: "11",
                        indexToAnimate: { _ in }
                    )

                    expect(viewModel.passcodeToFill).to(equal("11"))
                }
            }

            context("when entered passcode contains 3 or more digits") {
                context("when state is .check") {
                    it("it should call checkPasscode() and set state to .create") {
                        PasscodeManager.set(passcode: "1111")

                        let viewModel = PasscodeViewModel(purpose: .edit)
                        
                        expect(viewModel.state.value).to(equal(PasscodeViewModelState.check))
                        
                        viewModel.didInput(digit: "1", indexToAnimate: { _ in })
                        viewModel.didInput(digit: "1", indexToAnimate: { _ in })
                        viewModel.didInput(digit: "1", indexToAnimate: { _ in })
                        viewModel.didInput(digit: "1", indexToAnimate: { _ in })

                        expect(viewModel.state.value).toEventually(equal(PasscodeViewModelState.create(l10n(.newPasscode))))
                    }
                }

                context("when state is .create") {
                    it("it should switch to .repeat") {
                        PasscodeManager.set(passcode: "1111")

                        let viewModel = PasscodeViewModel(purpose: .create)
                        
                        expect(viewModel.state.value).to(equal(PasscodeViewModelState.create(l10n(.createPasscode))))
                        
                        viewModel.didInput(digit: "1", indexToAnimate: { _ in })
                        viewModel.didInput(digit: "1", indexToAnimate: { _ in })
                        viewModel.didInput(digit: "1", indexToAnimate: { _ in })
                        viewModel.didInput(digit: "1", indexToAnimate: { _ in })

                        expect(viewModel.state.value).toEventually(equal(PasscodeViewModelState.repeat))
                    }
                }

                context("when state is .repeat") {
                    it("it should call comparePasscodes") {
                        let viewModel = PasscodeViewModel(purpose: .create)
                        
                        expect(viewModel.state.value).to(equal(PasscodeViewModelState.create(l10n(.createPasscode))))
                        
                        viewModel.didInput(digit: "2", indexToAnimate: { _ in })
                        viewModel.didInput(digit: "2", indexToAnimate: { _ in })
                        viewModel.didInput(digit: "2", indexToAnimate: { _ in })
                        viewModel.didInput(digit: "2", indexToAnimate: { _ in })

                        expect(viewModel.state.value).toEventually(equal(PasscodeViewModelState.repeat))

                        viewModel.didInput(digit: "2", indexToAnimate: { _ in })
                        viewModel.didInput(digit: "2", indexToAnimate: { _ in })
                        viewModel.didInput(digit: "2", indexToAnimate: { _ in })
                        viewModel.didInput(digit: "2", indexToAnimate: { _ in })

                        expect(PasscodeManager.current).toEventually(equal("2222"))
                        expect(viewModel.state.value).toEventually(equal(PasscodeViewModelState.correct))
                    }
                }

                context("indexToAnimate") {
                    it("should return correct index which is needed to animate") {
                        let viewModel = PasscodeViewModel(purpose: .create)

                        viewModel.didInput(
                            digit: "2",
                            indexToAnimate: { index in
                                expect(index).to(equal(0))
                            }
                        )

                        viewModel.didInput(
                            digit: "3",
                            indexToAnimate: { index in
                                expect(index).to(equal(1))
                            }
                        )
                    }
                }
            }
        }
        
        describe("clearPressed") {
            context("when clear pressed") {
                it("should clear digits one by one") {
                    let viewModel = PasscodeViewModel(purpose: .enter)
                    
                    viewModel.didInput(digit: "2222", indexToAnimate: { _ in })
                    
                    expect(viewModel.passcodeToFill).to(equal("2222"))
                    
                    viewModel.clearPressed(indexToAnimate: { _ in })
                    
                    expect(viewModel.passcodeToFill).to(equal("222"))
                }
            }

            context("indexToAnimate") {
                it("should return correct index which is needed to animate") {
                    let viewModel = PasscodeViewModel(purpose: .create)

                    viewModel.didInput(digit: "22", indexToAnimate: { _ in })

                    viewModel.clearPressed(
                        indexToAnimate: { index in
                            expect(index).to(equal(1))
                        }
                    )

                    viewModel.clearPressed(
                        indexToAnimate: { index in
                            expect(index).to(equal(0))
                        }
                    )
                }
            }
        }

        describe("wrong passcode") {
            it("should set view model state to .wrongPasscode") {
                let viewModel = PasscodeViewModel(purpose: .edit)

                expect(viewModel.state.value).to(equal(PasscodeViewModelState.check))

                viewModel.wrongPasscode()

                expect(viewModel.state.value).to(equal(PasscodeViewModelState.wrong))
            }
        }

        describe("switchToCreate") {
            it("should set view model state to .switchToCreate") {
                let viewModel = PasscodeViewModel(purpose: .edit)

                expect(viewModel.state.value).to(equal(PasscodeViewModelState.check))

                viewModel.switchToCreate()

                expect(viewModel.state.value).to(equal(PasscodeViewModelState.create(l10n(.newPasscode))))
            }
        }

        describe("checkPasscode") {
            context("when passcode is correct and purpose is .edit") {
                it("should switch to create") {
                    let viewModel = PasscodeViewModel(purpose: .edit)

                    PasscodeManager.set(passcode: "11")

                    viewModel.didInput(digit: "11", indexToAnimate: { _ in })

                    expect(viewModel.passcodeToFill).to(equal(PasscodeManager.current))

                    viewModel.checkPasscode()

                    expect(viewModel.state.value).to(equal(PasscodeViewModelState.create(l10n(.newPasscode))))
                }
            }

            context("when passcode is correct and purpose is .enter") {
                it("should set state to .correct") {
                    let viewModel = PasscodeViewModel(purpose: .enter)

                    PasscodeManager.set(passcode: "11")

                    viewModel.didInput(digit: "11", indexToAnimate: { _ in })

                    expect(viewModel.passcodeToFill).to(equal(PasscodeManager.current))

                    viewModel.checkPasscode()

                    expect(viewModel.state.value).to(equal(PasscodeViewModelState.correct))
                }
            }

            context("when passcode is not correct to current passcode") {
                it("should set state to .wrong, then to .check") {
                    let viewModel = PasscodeViewModel(purpose: .enter)

                    PasscodeManager.set(passcode: "11")

                    viewModel.didInput(digit: "55", indexToAnimate: { _ in })

                    viewModel.checkPasscode()

                    expect(viewModel.state.value).to(equal(PasscodeViewModelState.check))
                }
            }
        }

        describe("comparePasscodes") {
            context("when passcodes match") {
                it("should set new passcode") {
                    let viewModel = PasscodeViewModel(purpose: .create)

                    viewModel.didInput(digit: "11", indexToAnimate: { _ in })
                    
                    viewModel.state.value = .repeat

                    viewModel.didInput(digit: "11", indexToAnimate: { _ in })

                    viewModel.comparePasscodes()

                    expect(PasscodeManager.current).to(equal("11"))
                    expect(viewModel.state.value).to(equal(PasscodeViewModelState.correct))
                }
            }

            context("when confirmation passcode is not equal to passcode, entered on first step") {
                it("should switch to .create") {
                    let viewModel = PasscodeViewModel(purpose: .create)

                    viewModel.didInput(digit: "11", indexToAnimate: { _ in })

                    
                    viewModel.state.value = .repeat

                    viewModel.didInput(digit: "33", indexToAnimate: { _ in })

                    viewModel.comparePasscodes()

                    expect(PasscodeManager.current).to(beEmpty())
                    expect(viewModel.state.value).to(equal(PasscodeViewModelState.create(l10n(.createPasscode))))
                }
            }
        }
    }
}
