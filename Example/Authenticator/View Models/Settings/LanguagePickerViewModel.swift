//
//  LanguagePickerViewModel.swift
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2020 Salt Edge Inc.
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

protocol LanguagePickerEventsDelegate: class {
    func languageSelected()
}

final class LanguagePickerViewModel {
    private var items: [String] {
        return LocalizationHelper.languageDisplayNamesForAvailableLocalizations()
    }
    private var selectedLanguageCode = UserDefaultsHelper.applicationLanguage

    weak var delegate: LanguagePickerEventsDelegate?

    var sections: Int {
        return 1
    }

    func rows(for section: Int) -> Int {
        return items.count
    }

    func cellTitle(for indexPath: IndexPath) -> String {
        return items[indexPath.row]
    }

    func cellAccessoryType(for indexPath: IndexPath) -> UITableViewCell.AccessoryType {
        let selectedLanguageName = LocalizationHelper.languageDisplayName(from: selectedLanguageCode)
        return selectedLanguageName == cellTitle(for: indexPath) ? .checkmark : .none
    }

    func selected(indexPath: IndexPath) {
        if let newSelectedLanguageCode = LocalizationHelper.languageCode(from: cellTitle(for: indexPath)) {
            UserDefaultsHelper.applicationLanguage = newSelectedLanguageCode
            delegate?.languageSelected()
        }
    }
}
