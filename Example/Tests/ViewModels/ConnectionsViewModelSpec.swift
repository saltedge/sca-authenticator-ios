//
//  ConnectionsViewModelSpec
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

import Foundation
import Quick
import Nimble
import UIKit
import SEAuthenticator
import RealmSwift
@testable import SEAuthenticatorCore

private final class MockSettingsDelegate: ConnectionsEventsDelegate {
    
    var showEditConnectionAlertCall: Bool = false
    var showSupportCall: Bool = false
    var deleteConnectionCall: Bool = false
    var reconnectCall: Bool = false
    var consentsPressedCall: Bool = false
    var updateViewsCall: Bool = false
    var addPressedCall: Bool = false
    var presentErrorCall: Bool = false
    var showNoInternetConnectionAlertCall: Bool = false
    var showDeleteConfirmationAlertCall: Bool = false
    
    func showEditConnectionAlert(placeholder: String, completion: @escaping (String) -> ()) {
        showEditConnectionAlertCall = true
    }
    
    func showSupport(email: String) {
        showSupportCall = true
    }
    
    func deleteConnection(completion: @escaping () -> ()) {
        deleteConnectionCall = true
    }
    
    func reconnect(by id: String) {
        reconnectCall = true
    }
    
    func consentsPressed(connectionId: String, consents: [SEConsentData]) {
        consentsPressedCall = true
    }
    
    func updateViews() {
        updateViewsCall = true
    }
    
    func addPressed() {
        addPressedCall = true
    }
    
    func presentError(_ error: String) {
        presentErrorCall = true
    }
    
    func showNoInternetConnectionAlert(completion: @escaping () -> Void) {
        showNoInternetConnectionAlertCall = true
    }
    
    func showDeleteConfirmationAlert(completion: @escaping () -> Void) {
        showDeleteConfirmationAlertCall = true
    }
}


final class ConnectionsViewModelSpec: BaseSpec {
    
    override func spec() {
        beforeEach {
            ConnectionRepository.deleteAllConnections()
        }
                
        describe("count") {
            it("should return count of connections") {
                let viewModel = ConnectionsViewModel()
                let connection = Connection()
                connection.status = "active"

                ConnectionRepository.save(connection)
            
                expect(viewModel.count).to(equal(1))
            }
        }
        
        describe("hasDataToShow") {
            it("must display the data that needs to be shown") {
                let viewModel = ConnectionsViewModel()
                let connection = Connection()
                connection.status = "active"

                ConnectionRepository.save(connection)
                
                expect(viewModel.hasDataToShow).to(equal(true))
            }
            
            it("will not display the data to be displayed") {
                let viewModel = ConnectionsViewModel()
                
                expect(viewModel.hasDataToShow).to(equal(false))
            }
        }
        
        describe("emptyViewData") {
            context("when there is no connections") {
                it("should return correct data") {
                    let viewModel = ConnectionsViewModel()

                    let expectedEmptyViewData = EmptyViewData(
                        image: UIImage(named: "noConnections", in: .authenticator_main, compatibleWith: nil)!,
                        title: l10n(.noConnections),
                        description: l10n(.noConnectionsDescription),
                        buttonTitle: l10n(.connect)
                    )

                    expect(viewModel.emptyViewData).to(equal(expectedEmptyViewData))
                }
            }
        }
        
        describe("remove(id)") {
            context("remove connections") {
                it("should remove connection") {
                    let viewModel = ConnectionsViewModel()
                    let mockDelegate = MockSettingsDelegate()
                    viewModel.delegate = mockDelegate
                    
                    let connection = Connection()
                    connection.id = "id1"

                    ConnectionRepository.save(connection)

                    viewModel.remove(by: "id1")
                    
                    expect(viewModel.count).to(equal(0))
                }
            }
        }
        
        describe("checkInternetAndRemoveConnection") {
            context("remove connection when internet is on and showConfirmation is true") {
                it("should remove connection") {
                    let viewModel = ConnectionsViewModel()
                    let mockDelegate = MockSettingsDelegate()
                    viewModel.delegate = mockDelegate
                    
                    let connection = Connection()
                    connection.id = "id1"

                    ConnectionRepository.save(connection)

                    viewModel.checkInternetAndRemoveConnection(id: "id1", showConfirmation: true)
                    
                    expect(mockDelegate.showNoInternetConnectionAlertCall).to(beTrue())
                    expect(viewModel.count).to(equal(0))
                }
            }
        
            context("remove connection when internet is on and showConfirmation is false") {
                it("should remove connection") {
                    let viewModel = ConnectionsViewModel()
                    let mockDelegate = MockSettingsDelegate()
                    viewModel.delegate = mockDelegate
                    
                    let connection = Connection()
                    connection.id = "id1"

                    ConnectionRepository.save(connection)

                    viewModel.checkInternetAndRemoveConnection(id: "id1", showConfirmation: false)
                    
                    expect(mockDelegate.showNoInternetConnectionAlertCall).to(beTrue())
                    expect(viewModel.count).to(equal(0))
                }
            }
            
            context("remove connection when internet is off") {
                it("should remove connection") {
                    let viewModel = ConnectionsViewModel()
                    let mockDelegate = MockSettingsDelegate()
                    viewModel.delegate = mockDelegate
                    
                    let connection = Connection()
                    connection.id = "id1"

                    ConnectionRepository.save(connection)

                    viewModel.checkInternetAndRemoveConnection(id: "id1", showConfirmation: true)
                    
                    expect(mockDelegate.showDeleteConfirmationAlertCall).to(beTrue())
                    expect(viewModel.count).to(equal(0))
                }
            }
        }
    }
}

