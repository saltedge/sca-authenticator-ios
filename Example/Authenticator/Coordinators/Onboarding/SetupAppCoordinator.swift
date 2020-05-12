//
//  SetupAppCoordinator.swift
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

final class SetupAppCoordinator: Coordinator {
    private var rootViewController: UIViewController
    private let setupAppViewController = SetupAppViewController()
    private var appCoordinator: ApplicationCoordinator?

    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }

    func start() {
//        setupAppViewController.delegate = self
        setupAppViewController.modalPresentationStyle = .fullScreen
        rootViewController.navigationController?.present(setupAppViewController, animated: true)
    }

    func stop() {}
}

// MARK: - SetupAppViewControllerDelegate
extension SetupAppCoordinator: SetupAppViewControllerDelegate {
    func allowBiometricsPressed() {
        if BiometricsHelper.biometryType == .none {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            UIApplication.shared.open(
                settingsUrl,
                completionHandler: { [weak self] _ in
//                    self?.setupAppViewController.switchToNextStep()
                }
            )
        } else {
            PasscodeManager.useBiometrics(
                reasonString: "Authenticate app",
                onSuccess: { [weak self] in
                    PasscodeManager.isBiometricsEnabled = true
//                    self?.setupAppViewController.switchToNextStep()
                },
                onFailure: { [weak self] error in
                    if error.isBiometryLockout {
                        self?.setupAppViewController.showConfirmationAlert(
                            withTitle: error.localizedDescription,
                            message: "You have to reconfigure your biometry in settings.",
                            cancelTitle: l10n(.ok),
                            cancelAction: { _ in
//                                self?.setupAppViewController.switchToNextStep()
                            }
                        )
                    }
                    print(error.localizedDescription)
                }
            )
        }
    }

    func allowNotificationsViewAction() {
        NotificationsManager.registerForNotifications(
            success: { [weak self] _ in
//                DispatchQueue.main.async { self?.setupAppViewController.switchToNextStep() }
            },
            failure: { [weak self] in
                DispatchQueue.main.async {
                    self?.setupAppViewController.showConfirmationAlert(withTitle: "Please, enable notifications in settings.")
                }
            }
        )
    }

    func procceedPressed() {
        UserDefaultsHelper.didShowOnboarding = true
        appCoordinator = ApplicationCoordinator(window: AppDelegate.main.window)
        appCoordinator?.start()
    }
}
