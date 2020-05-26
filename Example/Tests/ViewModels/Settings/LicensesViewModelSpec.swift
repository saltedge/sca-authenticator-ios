//
//  LicensesViewModelSpec.swift
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

private final class MockLicensesDelegate: LicensesEventsDelegate {
    var licenceSelectedCall: URL? = nil
    
    func licenceSelected(with url: URL) {
        licenceSelectedCall = url
    }
}

class LicensesViewModelSpec: BaseSpec {
    override func spec() {
        let viewModel = LicensesViewModel()
        
        describe("sections") {
            it("should return correct number of sections") {
                expect(viewModel.sections).to(equal(1))
            }
        }
        
        describe("rows") {
            it("should return correct number of rows") {
                expect(viewModel.rows(for: 0)).to(equal(10))
            }
        }

        describe("cellTitle(for indexPath)") {
            it("should return the proper cell title for index path") {
                expect(viewModel.cellTitle(for: IndexPath(row: 0, section: 0)))
                .to(equal("ReachabilitySwift"))
                expect(viewModel.cellTitle(for: IndexPath(row: 1, section: 0)))
                .to(equal("TinyConstraints"))
                expect(viewModel.cellTitle(for: IndexPath(row: 2, section: 0)))
                .to(equal("SDWebImage"))
                expect(viewModel.cellTitle(for: IndexPath(row: 3, section: 0)))
                .to(equal("Realm Swift"))
                expect(viewModel.cellTitle(for: IndexPath(row: 4, section: 0)))
                .to(equal("Square/Valet"))
                expect(viewModel.cellTitle(for: IndexPath(row: 5, section: 0)))
                .to(equal("Typist"))
                expect(viewModel.cellTitle(for: IndexPath(row: 6, section: 0)))
                .to(equal("Firebase"))
                expect(viewModel.cellTitle(for: IndexPath(row: 7, section: 0)))
                .to(equal("SwiftyAttributes"))
                expect(viewModel.cellTitle(for: IndexPath(row: 8, section: 0)))
                .to(equal("Quick/Nimble"))
                expect(viewModel.cellTitle(for: IndexPath(row: 9, section: 0)))
                .to(equal("CryptoSwift"))
            }
        }
        
        describe("selected(for indexPath)") {
            it("should call delegate.licenceSelected()") {
                let mockDelegate = MockLicensesDelegate()
                viewModel.delegate = mockDelegate
                let indexPath = IndexPath(row: 0, section: 0)
                
                viewModel.selected(indexPath: indexPath)

                expect(mockDelegate.licenceSelectedCall)
                .to(equal(URL(string: "https://raw.githubusercontent.com/ashleymills/Reachability.swift/master/LICENSE")))
            }
        }
    }
}
