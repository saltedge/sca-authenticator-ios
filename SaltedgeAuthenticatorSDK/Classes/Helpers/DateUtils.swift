//
//  DateUtils.swift
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

public struct DateUtils {
    static var iso8601dateFormatter: DateFormatter {
        return sharedInstance.iso8601dateFormatter
    }
    
    private static let sharedInstance = DateUtils()
    
    // NOTE: We use XXXXX instead of Z to avoid appending of GMT offset
    private var iso8601dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
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
