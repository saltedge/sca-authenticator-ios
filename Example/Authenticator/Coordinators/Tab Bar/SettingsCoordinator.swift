//
//  SettingsCoordinator.swift
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

final class SettingsCoordinator: Coordinator {
    let rootViewController = SettingsViewController()

    private var passcodeCoordinator: PasscodeCoordinator?
    private var languageCoordinator: LanguageCoordinator?
    private var aboutCoordinator: AboutCoordinator?

    private let dataSource = SettingsDataSource()

    func start() {
        rootViewController.delegate = self
    }

    func stop() {}
}

// MARK: - SettingsViewControllerDelegate
extension SettingsCoordinator: SettingsViewControllerDelegate {
    func selected(_ item: SettingsCellType, indexPath: IndexPath) {
        switch item {
        case .support: rootViewController.showSupportMailComposer()
        case .passcode:
            let newPasscodeViewController = NewPasscodeViewController(purpose: .edit)
            newPasscodeViewController.hidesBottomBarWhenPushed = true
            rootViewController.navigationController?.pushViewController(newPasscodeViewController, animated: true)
        case .language:
            languageCoordinator = LanguageCoordinator(rootViewController: rootViewController)
            languageCoordinator?.start()
        case .about:
            aboutCoordinator = AboutCoordinator(rootViewController: rootViewController)
            aboutCoordinator?.start()
        case .clearData:
            rootViewController.showConfirmationAlert(
                withTitle: "\(l10n(.clearData))?",
                message: l10n(.clearDataDescription),
                confirmActionTitle: l10n(.ok),
                confirmActionStyle: .default,
                confirmAction: { _ in
                    RealmManager.deleteAll()
                    CacheHelper.clearCache()
                }
            )
        default: break
        }
    }
}
