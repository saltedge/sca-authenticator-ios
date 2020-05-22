//
//  SettingsViewModel.swift
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

protocol SettingsEventsDelegate: class {
    func showChangeLanguageView()
    func showChangePasscodeView()
    func showSupportView()
    func showAboutView()
    func askUserToConfirmClearData(confirmAction: @escaping ((UIAlertAction) -> ()))
}

class SettingsViewModel {
    private let data: [(String, [SettingsCellType])] = [
        (l10n(.general), [.language, .passcode, .biometrics]),
        (l10n(.info), [.about, .support]),
        ("", [.clearData])
    ]

    weak var delegate: SettingsEventsDelegate?

    var sections: Int {
        return data.count
    }

    func rows(for section: Int) -> Int {
        return data[section].1.count
    }

    func item(for indexPath: IndexPath) -> SettingsCellType? {
        return data[indexPath.section].1[indexPath.row]
    }

    func title(for section: Int) -> String {
        return data[section].0
    }
    
    func selected(_ item: SettingsCellType, indexPath: IndexPath) {
        switch item {
        case .language:
            delegate?.showChangeLanguageView()
        case .passcode:
            delegate?.showChangePasscodeView()
        case .support:
            delegate?.showSupportView()
        case .about:
            delegate?.showAboutView()
        case .clearData:
            delegate?.askUserToConfirmClearData(confirmAction: { _ in
                RealmManager.deleteAll()
                CacheHelper.clearCache()
            })
        default: break
        }
    }
}
