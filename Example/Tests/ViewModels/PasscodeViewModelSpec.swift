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

        describe("didInput(digit:, symbols:)") {
            context("when entered passcode contains less than 3 digits") {
                it("should sppend to passcode") {
                    let viewModel = PasscodeViewModel(purpose: .create)

                    expect(viewModel.passcodeToFill).to(beEmpty())

                    viewModel.didInput(digit: "11", symbols: [PasscodeSymbolView(), PasscodeSymbolView(), PasscodeSymbolView()])

                    expect(viewModel.passcodeToFill).to(equal("11"))
                }
            }

            context("when entered passcode contains 3 or more digits") {
                context("when state is .check") {
                    it("it should call checkPasscode() and set state to .create") {
                        PasscodeManager.set(passcode: "1111")

                        let symbols = [PasscodeSymbolView(), PasscodeSymbolView(), PasscodeSymbolView(), PasscodeSymbolView()]

                        let viewModel = PasscodeViewModel(purpose: .edit)
                        
                        expect(viewModel.state.value).to(equal(PasscodeViewModelState.check))
                        
                        viewModel.didInput(digit: "1", symbols: symbols)
                        viewModel.didInput(digit: "1", symbols: symbols)
                        viewModel.didInput(digit: "1", symbols: symbols)
                        viewModel.didInput(digit: "1", symbols: symbols)

                        expect(viewModel.state.value).to(equal(PasscodeViewModelState.create(showLabel: false)))
                    }
                }

                context("when state is .create") {
                    it("it should switch to .repeat") {
                        PasscodeManager.set(passcode: "1111")

                        let symbols = [PasscodeSymbolView(), PasscodeSymbolView(), PasscodeSymbolView(), PasscodeSymbolView()]

                        let viewModel = PasscodeViewModel(purpose: .create)
                        
                        expect(viewModel.state.value).to(equal(PasscodeViewModelState.create(showLabel: false)))
                        
                        viewModel.didInput(digit: "1", symbols: symbols)
                        viewModel.didInput(digit: "1", symbols: symbols)
                        viewModel.didInput(digit: "1", symbols: symbols)
                        viewModel.didInput(digit: "1", symbols: symbols)

                        expect(viewModel.state.value).to(equal(PasscodeViewModelState.repeat))
                    }
                }

                context("when state is .repeat") {
                    it("it should call comparePasscodes") {
                        let symbols = [PasscodeSymbolView(), PasscodeSymbolView(), PasscodeSymbolView(), PasscodeSymbolView()]

                        let viewModel = PasscodeViewModel(purpose: .create)
                        
                        expect(viewModel.state.value).to(equal(PasscodeViewModelState.create(showLabel: false)))
                        
                        viewModel.didInput(digit: "2", symbols: symbols)
                        viewModel.didInput(digit: "2", symbols: symbols)
                        viewModel.didInput(digit: "2", symbols: symbols)
                        viewModel.didInput(digit: "2", symbols: symbols)

                        expect(viewModel.state.value).to(equal(PasscodeViewModelState.repeat))

                        viewModel.didInput(digit: "2", symbols: symbols)
                        viewModel.didInput(digit: "2", symbols: symbols)
                        viewModel.didInput(digit: "2", symbols: symbols)
                        viewModel.didInput(digit: "2", symbols: symbols)

                        expect(PasscodeManager.current).to(equal("2222"))
                        expect(viewModel.state.value).to(equal(PasscodeViewModelState.correct))
                    }
                }
            }
        }
        
        describe("clearPressed") {
            it("should clear digits one by one") {
                let symbols = [PasscodeSymbolView(), PasscodeSymbolView(), PasscodeSymbolView(), PasscodeSymbolView()]

                let viewModel = PasscodeViewModel(purpose: .enter)
                
                viewModel.didInput(digit: "2222", symbols: symbols)

                expect(viewModel.passcodeToFill).to(equal("2222"))

                viewModel.clearPressed(symbols: symbols)

                expect(viewModel.passcodeToFill).to(equal("222"))
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

                viewModel.switchToCreate(showLabel: false)

                expect(viewModel.state.value).to(equal(PasscodeViewModelState.create(showLabel: false)))
            }
        }

        describe("checkPasscode") {
            context("when passcode is correct and purpose is .edit") {
                it("should switch to create") {
                    let viewModel = PasscodeViewModel(purpose: .edit)

                    PasscodeManager.set(passcode: "11")

                    viewModel.didInput(digit: "11", symbols: [PasscodeSymbolView(), PasscodeSymbolView(), PasscodeSymbolView()])

                    expect(viewModel.passcodeToFill).to(equal(PasscodeManager.current))

                    viewModel.checkPasscode()

                    expect(viewModel.state.value).to(equal(PasscodeViewModelState.create(showLabel: false)))
                }
            }

            context("when passcode is correct and purpose is .enter") {
                it("should set state to .correct") {
                    let viewModel = PasscodeViewModel(purpose: .enter)

                    PasscodeManager.set(passcode: "11")

                    viewModel.didInput(digit: "11", symbols: [PasscodeSymbolView(), PasscodeSymbolView(), PasscodeSymbolView()])

                    expect(viewModel.passcodeToFill).to(equal(PasscodeManager.current))

                    viewModel.checkPasscode()

                    expect(viewModel.state.value).to(equal(PasscodeViewModelState.correct))
                }
            }

            context("when passcode is not correct to current passcode") {
                it("should set state to .wrong, then to .check") {
                    let viewModel = PasscodeViewModel(purpose: .enter)

                    PasscodeManager.set(passcode: "11")

                    viewModel.didInput(digit: "55", symbols: [PasscodeSymbolView(), PasscodeSymbolView(), PasscodeSymbolView()])

                    viewModel.checkPasscode()

                    expect(viewModel.state.value).to(equal(PasscodeViewModelState.check))
                }
            }
        }

        describe("comparePasscodes") {
            context("when passcodes match") {
                it("should set new passcode") {
                    let viewModel = PasscodeViewModel(purpose: .create)

                    viewModel.didInput(digit: "11", symbols: [PasscodeSymbolView(), PasscodeSymbolView(), PasscodeSymbolView()])
                    
                    viewModel.state.value = .repeat

                    viewModel.didInput(digit: "11", symbols: [PasscodeSymbolView(), PasscodeSymbolView(), PasscodeSymbolView()])

                    viewModel.comparePasscodes()

                    expect(PasscodeManager.current).to(equal("11"))
                    expect(viewModel.state.value).to(equal(PasscodeViewModelState.correct))
                }
            }

            context("when confirmation passcode is not equal to passcode, entered on first step") {
                it("should switch to .create") {
                    let viewModel = PasscodeViewModel(purpose: .create)

                    viewModel.didInput(digit: "11", symbols: [PasscodeSymbolView(), PasscodeSymbolView(), PasscodeSymbolView()])
                    
                    viewModel.state.value = .repeat

                    viewModel.didInput(digit: "33", symbols: [PasscodeSymbolView(), PasscodeSymbolView(), PasscodeSymbolView()])

                    viewModel.comparePasscodes()

                    expect(PasscodeManager.current).to(beEmpty())
                    expect(viewModel.state.value).to(equal(PasscodeViewModelState.create(showLabel: true)))
                }
            }
        }
    }
}
