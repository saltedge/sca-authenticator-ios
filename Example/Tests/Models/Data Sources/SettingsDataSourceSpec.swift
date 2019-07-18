//
//  SettingsDataSourceSpec.swift
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
import UIKit

class SettingsDataSourceSpec: BaseSpec {
    override func spec() {
        let dataSource = SettingsDataSource()

        describe("sections") {
            it("should return number of sections") {
                expect(dataSource.sections).to(equal(4))
            }
        }

        describe("rows(for:)") {
            context("when sections exists") {
                it("should return number of rows") {
                    expect(dataSource.rows(for: 0)).to(equal(1))
                    expect(dataSource.rows(for: 1)).to(equal(2))
                    expect(dataSource.rows(for: 2)).to(equal(1))
                    expect(dataSource.rows(for: 3)).to(equal(1))
                }
            }

            context("when section doesn't exists") {
                it("should return 0") {
                    expect(dataSource.rows(for: 5)).to(equal(0))
                }
            }
        }

        describe("item(for:)") {
            context("when sections exists") {
                it("should return corresponding item") {
                    expect(dataSource.item(for: IndexPath(row: 0, section: 0))).to(equal(SettingsCellType.language))
                    expect(dataSource.item(for: IndexPath(row: 0, section: 1))).to(equal(SettingsCellType.passcode))
                    expect(dataSource.item(for: IndexPath(row: 1, section: 1))).to(equal(SettingsCellType.biometrics))
                    expect(dataSource.item(for: IndexPath(row: 0, section: 2))).to(equal(SettingsCellType.about))
                    expect(dataSource.item(for: IndexPath(row: 0, section: 3))).to(equal(SettingsCellType.support))
                }                                         
            }

            context("when section doesn't exists") {
                it("should return nil") {
                    expect(dataSource.item(for: IndexPath(row: 0, section: 5))).to(beNil())
                }
            }
        }
    }
}
