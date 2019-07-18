//
//  ConnectionCollectorSpec.swift
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
import RealmSwift

class ConnectionCollectorSpec: BaseSpec {
    override func spec() {
        var firstConnection, secondConnection: Connection!

        beforeEach {
            firstConnection = Connection()
            firstConnection.id = "first"
            firstConnection.accessToken = "12345aaa"
            firstConnection.status = "active"
            firstConnection.name = "First"

            ConnectionRepository.save(firstConnection)

            secondConnection = Connection()
            secondConnection.id = "second"
            secondConnection.accessToken = "6789bbb"
            secondConnection.status = "inactive"
            secondConnection.name = "Second"

            ConnectionRepository.save(secondConnection)
        }
        
        afterEach {
            ConnectionRepository.deleteAllConnections()
        }

        describe("allConnections") {
            it("should return array of all connections") {
                expect(Array(ConnectionsCollector.allConnections)).to(equal([firstConnection, secondConnection]))
            }
        }

        describe("activeConnections") {
            it("should return array only of active connections") {
                expect(Array(ConnectionsCollector.activeConnections)).to(equal([firstConnection]))
            }
        }

        describe("where:") {
            it("should properly serialize the arguments into the Object.filter call") {
                let whereString = "guid == '\(firstConnection.guid)'"
                let expectedModel = ConnectionsCollector.allConnections.first!
                let actualModel = ConnectionsCollector.where(whereString).first!

                expect(expectedModel).to(equal(actualModel))
            }
        }

        describe("connectionNames") {
            it("should return array of connection names") {
                expect(ConnectionsCollector.connectionNames).to(equal(["First", "Second"]))
            }
        }

        describe("with(id:)") {
            it("should return correct object by given id" ) {
                expect(ConnectionsCollector.with(id: "first")).to(equal(firstConnection))
            }
        }
    }
}
