//
//  ConnectionSpec.swift
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

class ConnectionSpec: BaseSpec {
    override func spec() {
        describe("primaryKey") {
            it("should return id as primary key") {
                expect(Connection.primaryKey()).to(equal("guid"))
            }
        }

        describe("baseUrl") {
            it("should return baseUrl of an Connection") {
                let connection = Connection()
                connection.baseUrlString = "test.com"

                expect(connection.baseUrl).to(equal(URL(string: "test.com")))
            }
        }
        
        describe("logoUrl") {
            it("should return baseUrl of an Connection") {
                let connection = Connection()
                connection.logoUrlString = "test.com"

                expect(connection.logoUrl).to(equal(URL(string: "test.com")))
            }
        }
        
        describe("isManaged") {
            it("should return true if object is stored in Db") {
                let connection = Connection()
                
                expect(connection.isManaged).to(beFalse())
                
                ConnectionRepository.save(connection)
                
                expect(connection.isManaged).to(beTrue())
            }
        }
    }
}
