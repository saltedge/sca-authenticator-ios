//
//  PasscodeCoordinator.swift
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

// TODO: Move some logic to view model. Think about routing.
final class PasscodeCoordinator: Coordinator {
    private var rootViewController: UIViewController

    private var currentViewController: PasscodeViewController
    private var blockedTimer: Timer?
    private var purpose: PasscodeViewModel.PasscodeViewMode
//    private var type: PasscodeType

    private var blockedAlert: UIAlertController?

    var onCompleteClosure: (() -> ())?
    var onDismissClosure: (() -> ())?

    init(rootViewController: UIViewController, purpose: PasscodeViewModel.PasscodeViewMode) {
        self.purpose = purpose
//        self.type = type
        self.rootViewController = rootViewController
        self.currentViewController = PasscodeViewController(purpose: purpose)
    }

    func start() {
//        passcodeVc.delegate = self
        currentViewController.modalPresentationStyle = .fullScreen

        blockAppIfNeeded()

        if purpose == .edit {
            let navigationController = UINavigationController(rootViewController: currentViewController)
            navigationController.modalPresentationStyle = .fullScreen
            rootViewController.present(navigationController, animated: true)
        } else {
            rootViewController.present(currentViewController, animated: true)
        }
    }

    func stop() {}

    func showBiometricsIfEnabled() {
        guard PasscodeManager.isBiometricsEnabled else { return }

        PasscodeManager.useBiometrics(
            reasonString: l10n(.unlockAuthenticator),
            onSuccess: {
                self.resetWrongPasscodeAttempts()
                self.currentViewController.dismiss(animated: true)
                self.onCompleteClosure?()
            },
            onFailure: { error in
                if error.isBiometryLockout {
                    self.currentViewController.showConfirmationAlert(
                        withTitle: error.localizedDescription,
                        message: "You have to reconfigure your biometry in settings.",
                        cancelTitle: l10n(.ok)
                    )
                }
                print(error.localizedDescription)
            }
        )
    }
}

// MARK: - Actions
private extension PasscodeCoordinator {
    func blockAppIfNeeded() {
        if let blockedTill = UserDefaultsHelper.blockedTill, Date() < blockedTill {
            presentWrongPasscodeAlert(with: blockedMessage(for: blockedTill))
        } else {
            UserDefaultsHelper.blockedTill = nil
            blockedTimer?.invalidate()
            blockedAlert?.dismiss(animated: true, completion: { self.blockedAlert = nil })
        }
    }

    func blockedMessage(for date: Date) -> String {
        let secondsLeft = Int(date.timeIntervalSinceNow)
        let minutesLeft = secondsLeft / 60 + 1
        let message = minutesLeft > 1 ? l10n(.wrongPasscode) : l10n(.wrongPasscodeSingular)
        return message.replacingOccurrences(of: "%{count}", with: "\(minutesLeft)")
    }

    func presentWrongPasscodeAlert(with message: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        currentViewController.present(alert, animated: true, completion: nil)
        blockedAlert = alert
        blockedTimer = Timer.scheduledTimer(
            timeInterval: 10.0,
            target: self,
            selector: #selector(updateBlockedState),
            userInfo: nil,
            repeats: true
        )
    }

    @objc func updateBlockedState() {
        guard let alert = blockedAlert else { return }

        if let blockedTill = UserDefaultsHelper.blockedTill, Date() < blockedTill {
            alert.title = blockedMessage(for: blockedTill)
        } else {
            alert.dismiss(animated: true, completion: { self.blockedAlert = nil })
            blockedTimer?.invalidate()
            UserDefaultsHelper.blockedTill = nil
        }
    }

    func handleWrongPasscodeAttemts() {
        UserDefaultsHelper.wrongPasscodeAttempts += 1
        switch UserDefaultsHelper.wrongPasscodeAttempts {
        case 6: UserDefaultsHelper.blockedTill = Date() + 60
        case 7: UserDefaultsHelper.blockedTill = Date() + 5 * 60
        case 8: UserDefaultsHelper.blockedTill = Date() + 15 * 60
        case 9: UserDefaultsHelper.blockedTill = Date() + 60 * 60
        case 10: UserDefaultsHelper.blockedTill = Date() + 60 * 60
        case 11: deleteAllData()
        default: break
        }
        blockAppIfNeeded()
    }

    func deleteAllData() {
        RealmManager.deleteAll()
        PasscodeManager.remove()
        UserDefaultsHelper.clearDefaults()
        CacheHelper.clearCache()
        AppDelegate.main.showApplicationResetPopup()
    }

    func resetWrongPasscodeAttempts() {
        UserDefaultsHelper.wrongPasscodeAttempts = 0
        UserDefaultsHelper.blockedTill = nil
        blockedTimer?.invalidate()
        blockedAlert = nil
    }
}

extension PasscodeCoordinator {
    func wrongPasswordEntered() {
        if purpose == .enter {
            handleWrongPasscodeAttemts()
        }
    }

    func completed() {
        currentViewController.dismiss(
            animated: true,
            completion: {
                self.onCompleteClosure?()
            }
        )
    }

    func biometricsPressed() {
        showBiometricsIfEnabled()
    }

    func closePressed() {
        onDismissClosure?()
    }
}
