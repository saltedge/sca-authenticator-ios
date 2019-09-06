//
//  ConnectionRepositorySpec.swift
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

import Foundation
import Quick
import Nimble
import RealmSwift

class ConnectionRepositorySpec: BaseSpec {
    override func spec() {
        beforeEach {
            ConnectionRepository.deleteAllConnections()
        }
        
        describe("setAccessTokenAndActive(_:)") {
            it("should set access token and connection status to active") {
                let connection = Connection()
                connection.status = "inactive"
                
                ConnectionRepository.setAccessTokenAndActive(
                    connection,
                    accessToken: "accessToken1"
                )
                
                expect(connection.accessToken).to(equal("accessToken1"))
                expect(connection.status).to(equal("active"))
                
                connection.status = "inactive"
                
                expect(connection.status).to(equal("inactive"))
                
                ConnectionRepository.save(connection)
                
                ConnectionRepository.setAccessTokenAndActive(
                    connection,
                    accessToken: "accessToken2"
                )
                
                expect(connection.accessToken).to(equal("accessToken2"))
                expect(connection.status).to(equal("active"))
            }
        }

        describe("setInactive(_:)") {
            it("should set connection status to inactive") {
                let connection = Connection()
                connection.status = "active"

                ConnectionRepository.save(connection)

                expect(connection.status).to(equal("active"))

                ConnectionRepository.setInactive(connection)

                expect(connection.status).to(equal("inactive"))
            }
        }

        describe("save(_:)") {
            it("should save a connection to realm") {
                let connection = Connection()

                expect(ConnectionRepository.save(connection)).to(beTrue())
                expect(ConnectionsCollector.allConnections.first!).to(equal(connection))
            }
        }

        describe("delete(_:)") {
            it("should save remove a connection from realm") {
                let connection = Connection()

                expect(ConnectionRepository.save(connection)).to(beTrue())
                expect(ConnectionsCollector.allConnections.first!).to(equal(connection))

                expect(ConnectionRepository.delete(connection)).to(beTrue())
                expect(ConnectionsCollector.allConnections).to(beEmpty())
            }
        }
    }
}
