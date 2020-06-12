//
//  SettingsViewModelSpec.swift
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
import UIKit

private final class MockSettingsDelegate: SettingsEventsDelegate {
    var languageItemSelectedCall: Bool = false
    var passcodeItemSelectedCall: Bool = false
    var supportItemSelectedCall: Bool = false
    var aboutItemSelectedCall: Bool = false
    var clearDataItemSelectedCall: Bool = false
    
    func languageItemSelected() {
        languageItemSelectedCall = true
    }
    
    func passcodeItemSelected() {
        passcodeItemSelectedCall = true
    }
    
    func supportItemSelected() {
        supportItemSelectedCall = true
    }
    
    func aboutItemSelected() {
        aboutItemSelectedCall = true
    }
    
    func clearDataItemSelected(confirmAction: @escaping ((UIAlertAction) -> ())) {
        clearDataItemSelectedCall = true
    }
}

class SettingsViewModelSpec: BaseSpec {
    override func spec() {
        let viewModel = SettingsViewModel()

        describe("sections") {
            it("should return number of sections") {
                expect(viewModel.sections).to(equal(3))
            }
        }

        describe("rows(for:)") {
            context("when sections exists") {
                it("should return number of rows") {
                    expect(viewModel.rows(for: 0)).to(equal(2))
                    expect(viewModel.rows(for: 1)).to(equal(2))
                    expect(viewModel.rows(for: 2)).to(equal(1))
                }
            }

            context("when section doesn't exists") {
                it("should return 0") {
                    expect(viewModel.rows(for: 53)).to(equal(0))
                }
            }
        }

        describe("item(for:)") {
            context("when sections exists") {
                it("should return corresponding item") {
                    expect(viewModel.item(for: IndexPath(row: 0, section: 0)))
                        .to(equal(SettingCellModel.passcode))
                    expect(viewModel.item(for: IndexPath(row: 1, section: 0)))
                        .to(equal(SettingCellModel.language))
                    
                    expect(viewModel.item(for: IndexPath(row: 0, section: 1)))
                        .to(equal(SettingCellModel.about))
                    expect(viewModel.item(for: IndexPath(row: 1, section: 1)))
                        .to(equal(SettingCellModel.support))

                    expect(viewModel.item(for: IndexPath(row: 0, section: 2)))
                        .to(equal(SettingCellModel.clearData))
                }                                         
            }

            context("when section doesn't exists") {
                it("should return nil") {
                    expect(viewModel.item(for: IndexPath(row: 0, section: 5))).to(beNil())
                }
            }
        }
        
        describe("title(for:)") {
            context("when sections exists") {
                it("should return corresponding item") {
                    expect(viewModel.title(for: 0)).to(equal(l10n(.general)))
                    expect(viewModel.title(for: 1)).to(equal(l10n(.info)))
                    expect(viewModel.title(for: 2)).to(equal(""))
                }
            }
        }
        
        describe("selected(indexPath:)") {
            context("when index exists") {
                it("should call corresponding delegate's method") {
                    let mockDelegate = MockSettingsDelegate()
                    viewModel.delegate = mockDelegate

                    viewModel.selected(indexPath: IndexPath(row: 0, section: 0))

                    expect(mockDelegate.passcodeItemSelectedCall).to(beTrue())
                    expect(mockDelegate.languageItemSelectedCall).to(beFalse())
                    expect(mockDelegate.supportItemSelectedCall).to(beFalse())
                    expect(mockDelegate.aboutItemSelectedCall).to(beFalse())
                    expect(mockDelegate.clearDataItemSelectedCall).to(beFalse())
                }

                it("should call corresponding delegate's method") {
                    let mockDelegate = MockSettingsDelegate()
                    viewModel.delegate = mockDelegate

                    viewModel.selected(indexPath: IndexPath(row: 1, section: 0))

                    expect(mockDelegate.passcodeItemSelectedCall).to(beFalse())
                    expect(mockDelegate.languageItemSelectedCall).to(beTrue())
                    expect(mockDelegate.supportItemSelectedCall).to(beFalse())
                    expect(mockDelegate.aboutItemSelectedCall).to(beFalse())
                    expect(mockDelegate.clearDataItemSelectedCall).to(beFalse())
                }

                it("should call corresponding delegate's method") {
                    let mockDelegate = MockSettingsDelegate()
                    viewModel.delegate = mockDelegate

                    viewModel.selected(indexPath: IndexPath(row: 0, section: 1))

                    expect(mockDelegate.passcodeItemSelectedCall).to(beFalse())
                    expect(mockDelegate.languageItemSelectedCall).to(beFalse())
                    expect(mockDelegate.supportItemSelectedCall).to(beFalse())
                    expect(mockDelegate.aboutItemSelectedCall).to(beTrue())
                    expect(mockDelegate.clearDataItemSelectedCall).to(beFalse())
                }

                it("should call corresponding delegate's method") {
                    let mockDelegate = MockSettingsDelegate()
                    viewModel.delegate = mockDelegate

                    viewModel.selected(indexPath: IndexPath(row: 1, section: 1))

                    expect(mockDelegate.passcodeItemSelectedCall).to(beFalse())
                    expect(mockDelegate.languageItemSelectedCall).to(beFalse())
                    expect(mockDelegate.supportItemSelectedCall).to(beTrue())
                    expect(mockDelegate.aboutItemSelectedCall).to(beFalse())
                    expect(mockDelegate.clearDataItemSelectedCall).to(beFalse())
                }

                it("should call corresponding delegate's method") {
                    let mockDelegate = MockSettingsDelegate()
                    viewModel.delegate = mockDelegate

                    viewModel.selected(indexPath: IndexPath(row: 0, section: 2))

                    expect(mockDelegate.passcodeItemSelectedCall).to(beFalse())
                    expect(mockDelegate.languageItemSelectedCall).to(beFalse())
                    expect(mockDelegate.supportItemSelectedCall).to(beFalse())
                    expect(mockDelegate.aboutItemSelectedCall).to(beFalse())
                    expect(mockDelegate.clearDataItemSelectedCall).to(beTrue())
                }
            }

            context("when index doesn't exists") {
                it("should not call nothing") {
                    let mockDelegate = MockSettingsDelegate()
                    viewModel.delegate = mockDelegate
                    
                    viewModel.selected(indexPath: IndexPath(row: 0, section: 55))
                    
                    expect(mockDelegate.passcodeItemSelectedCall).to(beFalse())
                    expect(mockDelegate.languageItemSelectedCall).to(beFalse())
                    expect(mockDelegate.supportItemSelectedCall).to(beFalse())
                    expect(mockDelegate.aboutItemSelectedCall).to(beFalse())
                    expect(mockDelegate.clearDataItemSelectedCall).to(beFalse())
                }
            }
        }
    }
}
