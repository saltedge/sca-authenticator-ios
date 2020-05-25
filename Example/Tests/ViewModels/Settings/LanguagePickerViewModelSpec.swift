//
//  LanguagePickerViewModelSpec.swift
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

class LanguagePickerViewModelSpec: BaseSpec {
    let viewModel = LanguagePickerViewModel()
    
    override func spec() {
        describe("sections") {
            it("should return correct number of sections") {
                expect(self.viewModel.sections).to(equal(1))
            }
        }
        
        describe("rows") {
            it("should return correct number of rows") {
                expect(self.viewModel.rows(for: 0)).to(equal(1))
            }
        }

        describe("cellTitle(for indexPath)") {
            it("should return the proper language for index path") {
                let indexPath = IndexPath(row: 0, section: 0)

                expect(self.viewModel.cellTitle(for: indexPath)).to(equal("English"))
            }
        }
        
        describe("cellAccessoryType(for indexPath)") {
            it("should return the AccessoryType.checked for index path") {
                let indexPath = IndexPath(row: 0, section: 0)

                expect(self.viewModel.cellAccessoryType(for: indexPath)).to(equal(UITableViewCell.AccessoryType.checkmark))
            }
        }
        
        describe("selected(for indexPath)") {
            it("should set UserDefaults and call delegate.languageSelected()") {
                let mockDelegate = MockLanguageDelegate()
                self.viewModel.delegate = mockDelegate
                let indexPath = IndexPath(row: 0, section: 0)
                
                self.viewModel.selected(indexPath: indexPath)

                expect(mockDelegate.languageSelectedCalled).to(equal(true))
                expect(UserDefaultsHelper.applicationLanguage).to(equal("en"))
            }
        }
    }
}

final class MockLanguageDelegate: LanguagePickerEventsDelegate {
    var languageSelectedCalled: Bool = false
    
    func languageSelected() {
        languageSelectedCalled = true
    }
}
