//
//  AboutDataSourceSpec
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

final class AboutDataSourceSpec: BaseSpec {
    let dataSource = AboutDataSource()

    override func spec() {
        describe("sections") {
            it("should return correct number of sections") {
                expect(self.dataSource.sections).to(equal(1))
            }
        }

        describe("rows(for)") {
            it("should return correct number of rows") {
                expect(self.dataSource.rows(for: 0)).to(equal(3))
            }
        }
        

        describe("item(for)") {
            it("should return SettingsCellType for given index") {
                expect(self.dataSource.item(for: IndexPath(row: 0, section: 0))).to(equal(SettingsCellType.appVersion))
                expect(self.dataSource.item(for: IndexPath(row: 1, section: 0))).to(equal(SettingsCellType.terms))
                expect(self.dataSource.item(for: IndexPath(row: 2, section: 0))).to(equal(SettingsCellType.licenses))
            }
        }
    }
}
