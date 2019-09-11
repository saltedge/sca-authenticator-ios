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

        beforeEach {
            let connection = Connection()
            connection.id = "12345"
            ConnectionRepository.save(connection)
            _ = SECryptoHelper.createKeyPair(with: SETagHelper.create(for: connection.guid))

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
            
            let encryptedData = try! SECryptoHelper.encrypt(authMessage.jsonString!, tag: SETagHelper.create(for: connection.guid))
            let secondEncryptedData = try! SECryptoHelper.encrypt(
                secondAuthMessage.jsonString!, tag: SETagHelper.create(for: connection.guid)
            )
            
            let dict = [
                "data": encryptedData.data,
                "key": encryptedData.key,
                "iv": encryptedData.iv,
                "connection_id": connection.id,
                "algorithm": "AES-256-CBC"
            ]

            let secondDict = [
                "data": secondEncryptedData.data,
                "key": secondEncryptedData.key,
                "iv": secondEncryptedData.iv,
                "connection_id": connection.id,
                "algorithm": "AES-256-CBC"
            ]

            let firstResponse = SEEncryptedAuthorizationResponse(dict)!
            let secondResponse = SEEncryptedAuthorizationResponse(secondDict)!

            let firstDecryptedData: SEDecryptedAuthorizationData = AuthorizationsPresenter.decryptedData(from: firstResponse)!
            let secondDecryptedData: SEDecryptedAuthorizationData = AuthorizationsPresenter.decryptedData(from: secondResponse)!

            firstModel = AuthorizationViewModel(firstDecryptedData)
            secondModel = AuthorizationViewModel(secondDecryptedData)

            dataSource.update(with: [firstDecryptedData, secondDecryptedData])
            //dataSource.update(with: [firstDecryptedData, secondDecryptedData])
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

        describe("remove(_:)") {
            context("when view model exists") {
                it("should remove it from array and as a result return it's index") {
                    expect(dataSource.rows).to(equal(2))
                    expect(dataSource.remove(firstModel)).to(equal(0))
                    expect(dataSource.rows).to(equal(1))
                }
            }
 
            context("when view model doesn't exist") {
                it("should return nil") {
                    expect(dataSource.remove(AuthorizationViewModel(connectionId: "111", authorizationId: "222"))).to(beNil())
                }
            }
        }

        describe("item(for)") {
            it("should return view model for given index") {
                expect(dataSource.viewModel(at: 0)).to(equal(firstModel))
                expect(dataSource.viewModel(at: 1)).to(equal(secondModel))
            }
        }
    }
}
