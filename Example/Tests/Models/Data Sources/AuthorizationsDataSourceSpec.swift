//
//  AuthorizationsDataSourceSpec.swift
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2019 Salt Edge Inc.
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
@testable import SEAuthenticator

class AuthorizationsDataSourceSpec: BaseSpec {
    override func spec() {
        var firstModel, secondModel: AuthorizationViewModel!
        let dataSource = AuthorizationsDataSource()
        var viewModelsArray = [AuthorizationViewModel]()
        var connection: Connection!

        beforeEach {
            connection = createConnection(id: "12345")

            let authMessage = ["id": "00000",
                               "connection_id": connection.id,
                               "title": "Authorization",
                               "description": "Test authorization",
                               "created_at": Date().iso8601string,
                               "expires_at": Date().addingTimeInterval(5.0 * 60.0).iso8601string]

            let secondAuthMessage = ["id": "00001",
                                     "connection_id": connection.id,
                                     "title": "Second Authorization",
                                     "description": "Test authorization",
                                     "created_at": Date().iso8601string,
                                     "expires_at": Date().addingTimeInterval(5.0 * 60.0).iso8601string]

            let firstDecryptedData = createAuthResponse(with: authMessage, id: connection.id, guid: connection.guid)
            let secondDecryptedData = createAuthResponse(with: secondAuthMessage, id: connection.id, guid: connection.guid)

            firstModel = AuthorizationViewModel(firstDecryptedData)
            secondModel = AuthorizationViewModel(secondDecryptedData)

            viewModelsArray.append(contentsOf: [firstModel, secondModel])

            _ = dataSource.update(with: [firstDecryptedData, secondDecryptedData])
        }

        afterEach {
            viewModelsArray.removeAll()
        }

        describe("merge") {
            context("when merged viewmodel is expired") {
                it("should merge it into initial viewModels array") {
                    let authMessage = ["id": "00002",
                                       "connection_id": connection.id,
                                       "title": "Authorization",
                                       "description": "Test authorization",
                                       "created_at": Date().addingTimeInterval(-10.0 * 60.0).iso8601string,
                                       "expires_at": Date().addingTimeInterval(-5.0 * 60.0).iso8601string]
                    let decryptedData = createAuthResponse(with: authMessage, id: connection.id, guid: connection.guid)
                    let firstExpiredViewModel = AuthorizationViewModel(decryptedData)!

                    let secondAuthMessage = ["id": "00003",
                                             "connection_id": connection.id,
                                             "title": "Authorization",
                                             "description": "Test authorization",
                                             "created_at": Date().addingTimeInterval(-10.0 * 60.0).iso8601string,
                                             "expires_at": Date().addingTimeInterval(-5.0 * 60.0).iso8601string]
                    let secondDecryptedData = createAuthResponse(with: secondAuthMessage, id: connection.id, guid: connection.guid)
                    let secondExpiredViewModel = AuthorizationViewModel(secondDecryptedData)!

                    expect(viewModelsArray.contains(firstExpiredViewModel)).toNot(beTrue())
                    expect(viewModelsArray.count).to(equal(2))

                    viewModelsArray = viewModelsArray.merge(array: [firstExpiredViewModel, secondExpiredViewModel])

                    expect(viewModelsArray.count).to(equal(4))
                    expect(viewModelsArray.contains(firstExpiredViewModel)).to(beTrue())
                    expect(viewModelsArray.contains(secondExpiredViewModel)).to(beTrue())
                }
            }

            context("when viewModel state isn't none") {
                it("should merge it with initial array") {
                    let message = ["id": "00004",
                                   "connection_id": connection.id,
                                   "title": "Second Authorization",
                                   "description": "Test authorization",
                                   "created_at": Date().iso8601string,
                                   "expires_at": Date().addingTimeInterval(10.0 * 60.0).iso8601string]
                    let decryptedData = createAuthResponse(with: message, id: connection.id, guid: connection.guid)
                    let viewModel = AuthorizationViewModel(decryptedData)!
                    viewModel.state = .denied

                    expect(viewModelsArray.count).to(equal(2))

                    viewModelsArray = viewModelsArray.merge(array: [viewModel])

                    expect(viewModelsArray.count).to(equal(3))
                    expect(viewModelsArray.contains(viewModel)).to(beTrue())
                }
            }

            context("when merged viewModel isn't expired") {
                it("shouldn't merge it") {
                    let message = ["id": "00005",
                                   "connection_id": connection.id,
                                   "title": "Second Authorization",
                                   "description": "Test authorization",
                                   "created_at": Date().iso8601string,
                                   "expires_at": Date().addingTimeInterval(10.0 * 60.0).iso8601string]
                    let decryptedData = createAuthResponse(with: message, id: connection.id, guid: connection.guid)
                    let viewModel = AuthorizationViewModel(decryptedData)!

                    expect(viewModelsArray.count).to(equal(2))
                    
                    viewModelsArray = viewModelsArray.merge(array: [viewModel])

                    expect(viewModelsArray.count).to(equal(2))
                    expect(viewModelsArray.contains(viewModel)).toNot(beTrue())
                }
            }
        }

        describe("sections") {
            it("should return numer of sections, that is equal to number of authorizations") {
                expect(dataSource.sections).to(equal(1))
            }
        }

        describe("hasDataToShow") {
            it("should return true") {
                expect(dataSource.hasDataToShow).to(beTrue())
            }
        }

        describe("rows(for)") {
            it("should always return 1") {
                expect(dataSource.rows).to(equal(2))
            }
        }

        describe("viewModel(at)") {
            context("when viewModel exists") {
                it("should return viewModel for given index") {
                    expect(dataSource.viewModel(at: 1)).to(equal(secondModel))
                }
            }

            context("when viewModel doesn't exist at given index") {
                it("should return nil") {
                    expect(dataSource.viewModel(at: 5)).to(beNil())
                }
            }
        }

        describe("viewModel(by:)") {
            context("when one of existed viewModels has connectionId and authorizationId equal for given params") {
                it("should return existed viewModel") {                
                    expect(dataSource.viewModel(by: "12345", authorizationId: "00000")).to(equal(firstModel))
                }
            }

            context("when given parameters doesn't suit any of existed viewModels") {
                it("should return nil") {
                    expect(dataSource.viewModel(by: "09876", authorizationId: "1234565657575")).to(beNil())
                }
            }
        }

        describe("index(of)") {
            context("when viewModel exists") {
                it("should return index of given viewModel") {
                    expect(dataSource.index(of: firstModel)).to(equal(0))
                }
            }

            context("when authorization doesn't exist") {
                it("should return nil") {
                    let secondAuthMessage = ["id": "123343543535",
                                             "connection_id": "113223",
                                             "title": "Zombie Authorization",
                                             "description": "Not existed",
                                             "created_at": Date().iso8601string,
                                             "expires_at": Date().addingTimeInterval(5.0 * 60.0).iso8601string]
                    let decryptedData = SEDecryptedAuthorizationData(secondAuthMessage)!
                    
                    expect(dataSource.index(of: AuthorizationViewModel(decryptedData)!)).to(beNil())
                }
            }
        }

        describe("item(for)") {
            it("should return view model for given index") {
                expect(dataSource.viewModel(at: 0)).to(equal(firstModel))
                expect(dataSource.viewModel(at: 1)).to(equal(secondModel))
            }
        }

        func createConnection(id: ID) -> Connection {
            let connection = Connection()
            connection.id = id
            ConnectionRepository.save(connection)
            _ = SECryptoHelper.createKeyPair(with: SETagHelper.create(for: connection.guid))

            return connection
        }

        func createAuthResponse(with authMessage: [String: Any], id: ID, guid: GUID) -> SEDecryptedAuthorizationData {
            let encryptedData = try! SECryptoHelper.encrypt(authMessage.jsonString!, tag: SETagHelper.create(for: guid))

            let dict = [
                "data": encryptedData.data,
                "key": encryptedData.key,
                "iv": encryptedData.iv,
                "connection_id": id,
                "algorithm": "AES-256-CBC"
            ]

            let response = SEEncryptedAuthorizationResponse(dict)!

            return AuthorizationsPresenter.decryptedData(from: response)!
        }
    }
}
