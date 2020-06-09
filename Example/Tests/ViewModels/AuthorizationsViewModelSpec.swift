//
//  AuthorizationsViewModelSpec
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
import SEAuthenticator

extension EmptyViewData: Equatable {
    static func == (lhs: EmptyViewData, rhs: EmptyViewData) -> Bool {
        return lhs.image == rhs.image
            && lhs.title == rhs.title
            && lhs.description == rhs.description
            && lhs.buttonTitle == rhs.buttonTitle
    }
}

final class AuthorizationsViewModelSpec: BaseSpec {
    override func spec() {
        describe("emptyViewData") {
            context("when there is no connections") {
                it("should return correct data") {
                    let viewModel = AuthorizationsViewModel()
                    let dataSource = AuthorizationsDataSource()
                    viewModel.dataSource = dataSource

                    expect(Array(ConnectionsCollector.allConnections)).to(beEmpty())

                    let expectedEmptyViewData = EmptyViewData(
                        image: UIImage(named: "noConnections", in: .authenticator_main, compatibleWith: nil)!,
                        title: l10n(.noConnections),
                        description: l10n(.noConnectionsDescription),
                        buttonTitle: l10n(.connect)
                    )

                    expect(viewModel.emptyViewData).to(equal(expectedEmptyViewData))
                }
            }

            context("when there is at least one connection") {
                it("should retun correct data") {
                    let viewModel = AuthorizationsViewModel()
                    let dataSource = AuthorizationsDataSource()
                    viewModel.dataSource = dataSource
                    
                    let expectedEmptyViewData = EmptyViewData(
                        image: UIImage(named: "noAuthorizations", in: .authenticator_main, compatibleWith: nil)!,
                        title: l10n(.noAuthorizations),
                        description: l10n(.noAuthorizationsDescription),
                        buttonTitle: nil
                    )

                    let connection = Connection()
                    connection.status = ConnectionStatus.active.rawValue
                    ConnectionRepository.save(connection)

                    expect(viewModel.emptyViewData).to(equal(expectedEmptyViewData))

                    ConnectionRepository.delete(connection)
                }
            }
        }

        describe("confirmAuthorization") {
            it("should set state to .processing, then to completion state") {
                let viewModel = AuthorizationsViewModel()
                let dataSource = AuthorizationsDataSource()
                viewModel.dataSource = dataSource

                let connection = SpecUtils.createConnection(id: "123")

                let authMessage = ["id": "00000",
                                   "connection_id": connection.id,
                                   "title": "Authorization",
                                   "description": "Test authorization",
                                   "created_at": Date().iso8601string,
                                   "expires_at": Date().addingTimeInterval(5.0 * 60.0).iso8601string]
        
                let decryptedData = SpecUtils.createAuthResponse(with: authMessage, id: connection.id, guid: connection.guid)

                _ = dataSource.update(with: [decryptedData])
    
                let detailViewModel = dataSource.viewModel(with: "00000")

                viewModel.confirmAuthorization(by: "00000")

                expect(detailViewModel?.state.value).to(equal(AuthorizationStateView.AuthorizationState.processing))
                expect(detailViewModel?.state.value).toEventually(equal(AuthorizationStateView.AuthorizationState.undefined))
            }
        }

        describe("denyAuthorization") {
            it("should set state to .processing, then to completion state") {
                let viewModel = AuthorizationsViewModel()
                let dataSource = AuthorizationsDataSource()
                viewModel.dataSource = dataSource

                let connection = SpecUtils.createConnection(id: "123")

                let authMessage = ["id": "00000",
                                   "connection_id": connection.id,
                                   "title": "Authorization",
                                   "description": "Test authorization",
                                   "created_at": Date().iso8601string,
                                   "expires_at": Date().addingTimeInterval(5.0 * 60.0).iso8601string]
        
                let decryptedData = SpecUtils.createAuthResponse(with: authMessage, id: connection.id, guid: connection.guid)

                _ = dataSource.update(with: [decryptedData])
    
                let detailViewModel = dataSource.viewModel(with: "00000")

                viewModel.denyAuthorization(by: "00000")

                expect(detailViewModel?.state.value).to(equal(AuthorizationStateView.AuthorizationState.processing))
                expect(detailViewModel?.state.value).toEventually(equal(AuthorizationStateView.AuthorizationState.undefined))
            }
        }
    }
}
