//
//  ConnectViewModelSpec
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

private final class MockСonnectDelegate: ConnectViewModelEventsDelegate {
    var showNoInternetConnectionAlertCall: Bool = false
    
    func showNoInternetConnectionAlert() {
        showNoInternetConnectionAlertCall = true
    }
}

final class ConnectViewModelSpec: BaseSpec {
    private var viewModel: ConnectViewModel!
    private var networkSpy: MockConnectable!
    
    override func spec() {
        beforeEach {
            self.networkSpy = MockConnectable()
            self.viewModel = ConnectViewModel(reachabilityManager: self.networkSpy)
        }
        afterEach {
            self.viewModel = nil
            self.networkSpy = nil
        }
        
        describe("checkInternetConnection") {
            context("check internet connection when internet is off") {
                it("should show internet connection alert") {
                    let mockDelegate = MockСonnectDelegate()
                    self.viewModel.delegate = mockDelegate
                    self.networkSpy.enabled = false

                    self.viewModel.checkInternetConnection()

                    expect(mockDelegate.showNoInternetConnectionAlertCall).to(beTrue())
                }
            }
            
            context("check internet connection when internet is on") {
                it("should show internet connection alert") {
                    let mockDelegate = MockСonnectDelegate()
                    self.viewModel.delegate = mockDelegate
                    self.networkSpy.enabled = true

                    self.viewModel.checkInternetConnection()

                    expect(mockDelegate.showNoInternetConnectionAlertCall).to(beFalse())
                }
            }
        }
    }
}
