//
//  DateUtils
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2021 Salt Edge Inc.
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

public struct DateUtils {
    static var iso8601dateFormatter: ISO8601DateFormatter {
        return shared.iso8601dateFormatter
    }

    public static var dateFormatter: DateFormatter {
        return shared.dateFormatter
    }

    public static var ymdDateFormatter: DateFormatter {
        return shared.ymdDateFormatter
    }

    private static let shared = DateUtils()

    private var iso8601dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = .utc
        formatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        return formatter
    }()

    fileprivate var ymdDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd"
        formatter.timeZone = TimeZone.utc
        return formatter
    }()

    fileprivate var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.utc
        return formatter
    }()
}

public extension String {
    var iso8601date: Date? {
        return DateUtils.iso8601dateFormatter.date(from: self)
    }
}

public extension Date {
    var iso8601string: String {
        return DateUtils.iso8601dateFormatter.string(from: self)
    }
}
