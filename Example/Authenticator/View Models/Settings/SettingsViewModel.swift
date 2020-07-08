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
    func languageItemSelected()
    func passcodeItemSelected()
    func supportItemSelected()
    func aboutItemSelected()
    func clearDataItemSelected(confirmAction: @escaping (() -> ()))
}

final class SettingsViewModel {
    private var items: [Int: [SettingCellModel]] = [0: [.passcode, .language, .about, .support],
                                                    1: [.clearData]]

    init() {
        NotificationsManager.isRegisteredRemoteNotifications { registered in
            if !registered {
                self.items[0]?.append(.notifications)
            } else {
                if let index = self.items[0]?.firstIndex(of: .notifications) {
                    self.items[0]?.remove(at: index)
                }
            }
        }
    }

    weak var delegate: SettingsEventsDelegate?

    var sections: Int {
        return 2
    }

    func rows(in section: Int) -> Int {
        return items[section]?.count ?? 0
    }

    func item(for indexPath: IndexPath) -> SettingCellModel? {
        return items[indexPath.section]?[indexPath.row]
    }

    func selected(indexPath: IndexPath) {
        guard let item = item(for: indexPath) else { return }

        switch item {
        case .language:
            delegate?.languageItemSelected()
        case .passcode:
            delegate?.passcodeItemSelected()
        case .support:
            delegate?.supportItemSelected()
        case .about:
            delegate?.aboutItemSelected()
        case .clearData:
            delegate?.clearDataItemSelected(
                confirmAction: {
                    RealmManager.deleteAll()
                    CacheHelper.clearCache()
                }
            )
        case .notifications:
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        default: break
        }
    }
}
