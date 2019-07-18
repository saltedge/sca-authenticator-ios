//
//  AboutDataSource.swift
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

import UIKit

struct AboutDataSource {
    private let data: [Int: [SettingsCellType]] = [
        0: [.appVersion, .terms]
    ]

    var sections: Int {
        return data.keys.count
    }

    func rows(for section: Int) -> Int {
        guard let items = data[section] else { return 0 }

        return items.count
    }

    func item(for indexPath: IndexPath) -> SettingsCellType? {
        guard let item = data[indexPath.section]?[indexPath.row] else { return nil }

        return item
    }

    func pageURL(for type: SettingsCellType) -> URL? {
        switch type {
        case .terms: return AppSettings.termsURL
        default: return nil
        }
    }
}
