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
    private var rootViewController: UIViewController
    private var currentViewController: SettingsViewController
    private let viewModel = SettingsViewModel()

    private var passcodeCoordinator: PasscodeCoordinator?
    private var languageCoordinator: LanguagePickerCoordinator?
    private var aboutCoordinator: AboutCoordinator?

    init(rootController: UIViewController) {
        self.rootViewController = rootController
        self.currentViewController = SettingsViewController(viewModel: viewModel)
    }

    func start() {
        viewModel.delegate = self
        rootViewController.navigationController?.pushViewController(currentViewController, animated: true)
    }

    func stop() {
        viewModel.delegate = nil
    }
}

// MARK: - SettingsEventsDelegate
extension SettingsCoordinator: SettingsEventsDelegate {
    func languageItemSelected() {
        languageCoordinator = LanguagePickerCoordinator(rootViewController: currentViewController)
        languageCoordinator?.start()
    }

    func passcodeItemSelected() {
        passcodeCoordinator = PasscodeCoordinator(
            rootViewController: currentViewController,
            purpose: .edit
        )
        passcodeCoordinator?.start()
    }

    func supportItemSelected() {
        currentViewController.showSupportMailComposer()
    }

    func aboutItemSelected() {
        aboutCoordinator = AboutCoordinator(rootViewController: currentViewController)
        aboutCoordinator?.start()
    }

    func clearDataItemSelected(confirmAction: @escaping ((UIAlertAction) -> ())) {
        currentViewController.showConfirmationAlert(
            withTitle: "\(l10n(.clearData))?",
            message: l10n(.clearDataDescription),
            confirmActionTitle: l10n(.ok),
            confirmActionStyle: .default,
            confirmAction: confirmAction
        )
    }
}
