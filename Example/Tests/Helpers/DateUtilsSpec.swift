//
//  DateUtilsSpec
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

class DateUtilsSpec: BaseSpec {
    override func spec() {
        describe("iso8601dateFormatter") {
            it("should return the proper ISO8601 date formatter") {
                let fmt = DateUtils.iso8601dateFormatter

                expect(fmt.dateFormat).to(equal("yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"))
                expect(fmt.timeZone).to(equal(TimeZone.utc))
                expect(fmt.locale).to(equal(Locale(identifier: "en_US_POSIX")))
                expect(fmt.calendar).to(equal(Calendar(identifier: .iso8601)))
            }
        }

        describe("iso8601date") {
            it("should return date in iso8601 format") {
                let dateString = "2013-07-21T11:02:02.000Z"

                var dateComponents = DateComponents()
                dateComponents.year = 2013
                dateComponents.month = 7
                dateComponents.day = 21
                dateComponents.timeZone = TimeZone.utc
                dateComponents.hour = 11
                dateComponents.minute = 02
                dateComponents.second = 02

                let calendar = Calendar(identifier: .iso8601)
                let expectedDate = calendar.date(from: dateComponents)

                expect(dateString.iso8601date).to(equal(expectedDate))
            }
        }

        describe("iso8601string") {
            it("should return iso8601 string") {
                let date = Date()
                let expectedResult = DateUtils.iso8601dateFormatter.string(from: date)

                expect(date.iso8601string).to(equal(expectedResult))
            }
        }
    }
}
