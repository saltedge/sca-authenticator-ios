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
        var firstModel, secondModel: AuthorizationDetailViewModel!
        let dataSource = AuthorizationsDataSource()
        var connection: Connection!

        beforeEach {
            connection = SpecUtils.createConnection(id: "12345")

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
    
            let firstDecryptedData = SpecUtils.createAuthResponse(with: authMessage, id: connection.id, guid: connection.guid)
            let secondDecryptedData = SpecUtils.createAuthResponse(with: secondAuthMessage, id: connection.id, guid: connection.guid)

            firstModel = AuthorizationDetailViewModel(firstDecryptedData, apiVersion: "1")
            secondModel = AuthorizationDetailViewModel(secondDecryptedData, apiVersion: "1")

            _ = dataSource.update(with: [firstDecryptedData, secondDecryptedData])
        }

        afterEach {
            dataSource.clearAuthorizations()
        }

        describe("update") {
            context("when new authorization is expired") {
                it("should skip it and refresh existed models") {
                    expect(dataSource.rows).to(equal(2))

                    let authMessage = ["id": "3456311111111114",
                                       "connection_id": connection.id,
                                       "title": "Authorization",
                                       "description": "Test authorization",
                                       "created_at": Date().iso8601string,
                                       "expires_at": Date().addingTimeInterval(-3.0 * 60.0).iso8601string]

                    let decryptedData = SpecUtils.createAuthResponse(with: authMessage, id: connection.id, guid: connection.guid)

                    _ = dataSource.update(with: [decryptedData])

                    expect(dataSource.rows).to(equal(0))
                }
            }

            context("when new authorization is not expired") {
                it("should map decrypted data into view model and remove old models") {
                    expect(dataSource.rows).to(equal(2))

                    let authMessage = ["id": "987",
                                       "connection_id": connection.id,
                                       "title": "Authorization",
                                       "description": "Test authorization",
                                       "created_at": Date().iso8601string,
                                       "expires_at": Date().addingTimeInterval(3.0 * 60.0).iso8601string]
                    let decryptedData = SpecUtils.createAuthResponse(with: authMessage, id: connection.id, guid: connection.guid)

                    _ = dataSource.update(with: [decryptedData])

                    expect(dataSource.rows).to(equal(1))
                }
            }

            context("when one of the new authorizations is not expired and other is expired") {
                it("should skip the expired one and map only valid one") {
                    expect(dataSource.rows).to(equal(2))

                    let expiredAuthId = "33333"
                    let validAuthId = "99999"

                    let expiredAuthMessage = ["id": expiredAuthId,
                                              "connection_id": connection.id,
                                              "title": "Expired Authorization",
                                              "description": "Test expired authorization",
                                              "created_at": Date().iso8601string,
                                              "expires_at": Date().addingTimeInterval(-3.0 * 60.0).iso8601string]
                    let expiredDecryptedData = SpecUtils.createAuthResponse(with: expiredAuthMessage, id: connection.id, guid: connection.guid)

                    let validAuthMessage = ["id": validAuthId,
                                            "connection_id": connection.id,
                                            "title": "Valid Authorization",
                                            "description": "Test valid authorization",
                                            "created_at": Date().iso8601string,
                                            "expires_at": Date().addingTimeInterval(3.0 * 60.0).iso8601string]
                    let validDecryptedData = SpecUtils.createAuthResponse(with: validAuthMessage, id: connection.id, guid: connection.guid)

                    _ = dataSource.update(with: [expiredDecryptedData, validDecryptedData])

                    expect(dataSource.rows).to(equal(1))
                    expect(dataSource.viewModel(with: validAuthId, apiVersion: "1"))
                        .to(equal(AuthorizationDetailViewModel(validDecryptedData,apiVersion: "1")))

                    expect(dataSource.viewModel(with: expiredAuthId, apiVersion: "1")).to(beNil())

                    _ = dataSource.update(with: [validDecryptedData])

                    expect(dataSource.rows).to(equal(1))
                    expect(dataSource.viewModel(with: validAuthId, apiVersion: "1"))
                        .to(equal(AuthorizationDetailViewModel(validDecryptedData, apiVersion: "1")))
                }
            }

            context("when new v2 authorizations were added") {
                it("should return both v1 and v2 authorizations") {
                    // new authorization v1
                    let validAuthMessage = ["id": "1111",
                                            "connection_id": connection.id,
                                            "title": "Valid Authorization",
                                            "description": "Test valid authorization",
                                            "created_at": Date().iso8601string,
                                            "expires_at": Date().addingTimeInterval(3.0 * 60.0).iso8601string]
                    let validDecryptedDataV1 = SpecUtils.createAuthResponse(with: validAuthMessage, id: connection.id, guid: connection.guid)

                    let connectionV2 = SpecUtils.createConnection(id: "999", apiVersion: "2")
                    let authorizationV2id = 30000

                    // new authorization v2
                    let authMessage: [String: Any] = ["title": "Authorization V2",
                                                      "authorization_code": "code",
                                                      "description": ["text": "Test valid authorization"],
                                                      "created_at": Date().iso8601string,
                                                      "expires_at": Date().addingTimeInterval(3.0 * 60.0).iso8601string]
                    let validDecryptedDataV2 = SpecUtils.createAuthResponseV2(
                        with: authMessage,
                        authorizationId: authorizationV2id,
                        connectionId: Int(connectionV2.id)!,
                        guid: connectionV2.guid
                    )

                    _ = dataSource.update(with: [validDecryptedDataV1, validDecryptedDataV2])

                    expect(dataSource.rows).to(equal(2))
                }
            }

            context("merge") {
                context("when one authorization expired and other was added") {
                    it("should keep the expired one and add the new one") {
                        expect(dataSource.rows).to(equal(2))

                        let authMessage = ["id": "909",
                                           "connection_id": connection.id,
                                           "title": "Expired Authorization",
                                           "description": "Test expired authorization",
                                           "created_at": Date().iso8601string,
                                           "expires_at": Date().addingTimeInterval(1.0).iso8601string]
                        let decryptedData = SpecUtils.createAuthResponse(with: authMessage, id: connection.id, guid: connection.guid)

                        _ = dataSource.update(with: [decryptedData])
                        sleep(1)

                        expect(dataSource.rows).to(equal(1))

                        let newAuthMessage = ["id": "910",
                                              "connection_id": connection.id,
                                              "title": "Expired Authorization",
                                              "description": "Test expired authorization",
                                              "created_at": Date().iso8601string,
                                              "expires_at": Date().addingTimeInterval(3.0 * 60.0).iso8601string]
                        let newDecryptedData = SpecUtils.createAuthResponse(with: newAuthMessage, id: connection.id, guid: connection.guid)

                        _ = dataSource.update(with: [newDecryptedData])

                        expect(dataSource.rows).to(equal(2))
                    }
                }
            }
        }

        describe("clearAuthoriations") {
            it("should remove all authorizations") {
                expect(dataSource.rows).to(equal(2))

                dataSource.clearAuthorizations()

                expect(dataSource.rows).to(equal(0))
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
                    let decryptedData = SEAuthorizationData(secondAuthMessage)!
                    
                    expect(dataSource.index(of: AuthorizationDetailViewModel(decryptedData, apiVersion: "1")!)).to(beNil())
                }
            }
        }
    }
}
