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
            firstConnection.baseUrlString = "https://firstConnectUrl.com"

            ConnectionRepository.save(firstConnection)

            secondConnection = Connection()
            secondConnection.id = "second"
            secondConnection.accessToken = "6789bbb"
            secondConnection.status = "inactive"
            secondConnection.name = "Second"
            secondConnection.baseUrlString = "https://someConnectUrl.com"

            ConnectionRepository.save(secondConnection)
        }
        
        afterEach {
            ConnectionRepository.deleteAllConnections()
        }

        describe("allConnections") {
            it("should return array of all connections") {
                expect(Set(ConnectionsCollector.allConnections)).to(equal(Set([firstConnection, secondConnection])))
            }
        }

        describe("activeConnections") {
            it("should return array only of active connections") {
                expect(Array(ConnectionsCollector.activeConnections)).to(equal([firstConnection]))
            }
        }

        describe("activeConnections(by connectUrl)") {
            it("should return array only of active connections filtered by connect url") {
                let thirdConnection = Connection()
                thirdConnection.id = "third"
                thirdConnection.status = "active"
                thirdConnection.baseUrlString = "https://firstConnectUrl.com"

                ConnectionRepository.save(thirdConnection)

                let fourthConnection = Connection()
                fourthConnection.id = "fourth"
                fourthConnection.status = "active"
                fourthConnection.baseUrlString = "https://secondConnectUrl.com"

                ConnectionRepository.save(fourthConnection)

                expect(Array(ConnectionsCollector.activeConnections(by: URL(string: "https://firstConnectUrl.com")!))).to(equal([firstConnection, thirdConnection]))
                
                expect(Array(ConnectionsCollector.activeConnections(by: URL(string: "https://secondConnectUrl.com")!))).to(equal([fourthConnection]))
            }
        }

        describe("where:") {
            it("should properly serialize the arguments into the Object.filter call") {
                let whereString = "guid == '\(firstConnection.guid)'"
                let actualModelId = ConnectionsCollector.where(whereString).first!.id

                expect("first").to(equal(actualModelId))
            }
        }

        describe("connectionNames") {
            it("should return array of connection names") {
                expect(Set(ConnectionsCollector.connectionNames)).to(equal(Set(["First", "Second"])))
            }
        }

        describe("with(id:)") {
            it("should return correct object by given id" ) {
                expect(ConnectionsCollector.with(id: "first")).to(equal(firstConnection))
            }
        }
    }
}
