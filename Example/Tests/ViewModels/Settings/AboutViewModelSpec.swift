//
//  AboutViewModelSpec.swift
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

private final class MockAboutDelegate: AboutEventsDelegate {
    var termsItemSelectedUrl: String? = nil
    var termsItemSelectedLabel: String? = nil
    var licensesItemSelectedCall: Bool = false
    
    func termsItemSelected(urlString: String, label: String) {
        termsItemSelectedUrl = urlString
        termsItemSelectedLabel = label
    }
    
    func licensesItemSelected() {
        licensesItemSelectedCall = true
    }
}

final class AboutViewModelSpec: BaseSpec {

    override func spec() {
        let viewModel = AboutViewModel()
        
        describe("sections") {
            it("should return correct number of sections") {
                expect(viewModel.sections).to(equal(1))
            }
        }

        describe("rows(for)") {
            it("should return correct number of rows") {
                expect(viewModel.rows(for: 0)).to(equal(3))
            }
        }

        describe("item(for)") {
            it("should return SettingCellModel for given index") {
                expect(viewModel.item(for: IndexPath(row: 0, section: 0)))
                    .to(equal(SettingCellModel.appVersion))
                expect(viewModel.item(for: IndexPath(row: 1, section: 0)))
                    .to(equal(SettingCellModel.terms))
                expect(viewModel.item(for: IndexPath(row: 2, section: 0)))
                    .to(equal(SettingCellModel.licenses))
            }
        }
        
        describe("selected(indexPath)") {
            it("should return do nothing for wrong index") {
                let mockDelegate = MockAboutDelegate()
                viewModel.delegate = mockDelegate
                let indexPath = IndexPath(row: 0, section: 0)
                
                viewModel.selected(indexPath: indexPath)
                
                expect(mockDelegate.termsItemSelectedUrl).to(beNil())
                expect(mockDelegate.termsItemSelectedLabel).to(beNil())
                expect(mockDelegate.licensesItemSelectedCall).to(beFalse())
            }
            
            it("should call delegate.termsItemSelected() for TERMS item") {
                let mockDelegate = MockAboutDelegate()
                viewModel.delegate = mockDelegate
                let indexPath = IndexPath(row: 1, section: 0)
                
                viewModel.selected(indexPath: indexPath)
                
                expect(mockDelegate.termsItemSelectedUrl)
                    .to(equal(AppSettings.termsURL.absoluteString))
                expect(mockDelegate.termsItemSelectedLabel)
                    .to(equal(SettingCellModel.terms.localizedLabel))
                expect(mockDelegate.licensesItemSelectedCall).to(beFalse())
            }
            
            it("should call delegate.licensesItemSelected() for LICENSES item") {
                let mockDelegate = MockAboutDelegate()
                viewModel.delegate = mockDelegate
                let indexPath = IndexPath(row: 2, section: 0)
                
                viewModel.selected(indexPath: indexPath)
                
                expect(mockDelegate.termsItemSelectedUrl).to(beNil())
                expect(mockDelegate.termsItemSelectedLabel).to(beNil())
                expect(mockDelegate.licensesItemSelectedCall).to(beTrue())
            }
        }
    }
}
