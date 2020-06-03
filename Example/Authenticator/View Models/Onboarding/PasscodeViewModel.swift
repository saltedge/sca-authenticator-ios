//
//  PasscodeViewModel
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

enum PasscodeViewModelState: Equatable {
    case check
    case wrong
    case create(showLabel: Bool)
    case correct
    case `repeat`

    static func == (lhs: PasscodeViewModelState, rhs: PasscodeViewModelState) -> Bool {
        switch (lhs, rhs) {
        case let (.create(show1), .create(show2)):
            return show1 == show2
        case (.check, .check),
             (.wrong, .wrong),
             (.repeat, .repeat),
             (.correct, .correct):
            return true
        default: return false
        }
    }
}

protocol PasscodeEventsDelegate: class {
    func biometricsPressed()
    func dismiss()
    func presentWrongPasscodeAlert(with message: String, title: String?, buttonTitle: String?)
    func dismissWrongPasscodeAlert()
}

final class PasscodeViewModel {
    enum PasscodeViewMode {
        case create
        case edit
        case enter
    }

    var state: Observable<PasscodeViewModelState>

    private var blockedTimer: Timer?
    private var blockedMessage = ""

    private var purpose: PasscodeViewModel.PasscodeViewMode
    private var passcode = ""
    private var confirmationPasscode = ""

    weak var delegate: PasscodeEventsDelegate?

    init(purpose: PasscodeViewModel.PasscodeViewMode) {
        self.purpose = purpose
        self.state = Observable<PasscodeViewModelState>(purpose == .create ? .create(showLabel: false) : .check)
    }

    var navigationItemTitle: String? {
        return purpose == .edit ? l10n(.changePasscode) : nil
    }

    var shouldHideLogo: Bool {
        return purpose == .edit
    }

    var shouldDismiss: Bool {
        return purpose != .create
    }

    var passcodeToFill: String {
        get {
            return state.value == .repeat ? confirmationPasscode : passcode
        }
        set {
            if state.value == .repeat {
                confirmationPasscode = newValue
            } else {
                passcode = newValue
            }
        }
    }

    func didInput(digit: String, indexToAnimate: (Int) -> ()) {
        guard passcodeToFill.count < 4 else { return }

        passcodeToFill.append(digit)
        indexToAnimate(passcodeToFill.count - 1)

        if passcodeToFill.count > 3 {
            after(0.15) {
                switch self.state.value {
                case .check: self.checkPasscode()
                case .create: self.switchToRepeat()
                case .repeat: self.comparePasscodes()
                default: break
                }
            }
        }
    }

    func clearPressed(indexToAnimate: (Int) -> ()) {
        guard passcodeToFill.count != 0 else { return }

        passcodeToFill = String(passcodeToFill.dropLast(1))

        indexToAnimate(passcodeToFill.count)
    }

    func checkPasscode() {
        guard passcode == PasscodeManager.current else {
            wrongPasscode()
            state.value = .check
            return
        }

        if purpose == .edit {
            switchToCreate(showLabel: false)
        } else {
            resetWrongPasscodeAttempts()
            state.value = .correct
        }
    }

    func comparePasscodes() {
        guard passcode == confirmationPasscode else {
            wrongPasscode()
            switchToCreate(showLabel: true)
            return
        }

        PasscodeManager.set(passcode: passcode)

        state.value = .correct
    }

    func wrongPasscode() {
        state.value = .wrong

        passcode = ""
        confirmationPasscode = ""

        if purpose == .enter {
            handleWrongPasscodeAttemts()
        }
    }

    func switchToCreate(showLabel: Bool) {
        state.value = .create(showLabel: showLabel)

        passcode = ""
    }

    func switchToRepeat() {
        state.value = .repeat
    }

    func showBiometrics(completion: (()->())?) {
        PasscodeManager.useBiometrics(
            reasonString: l10n(.unlockAuthenticator),
            onSuccess: {
                self.resetWrongPasscodeAttempts()
                completion?()
                self.delegate?.dismiss()
            },
            onFailure: { error in
                if error.isBiometryLockout {
                    self.delegate?.presentWrongPasscodeAlert(
                        with: l10n(.biometricsNotAvailableDescription),
                        title: error.localizedDescription,
                        buttonTitle: l10n(.ok)
                    )
                }
            }
        )
    }

    func goToSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }

    func blockAppIfNeeded() {
        guard purpose == .enter else { return }

        if let blockedTill = UserDefaultsHelper.blockedTill, Date() < blockedTill {
            blockedTimer = Timer.scheduledTimer(
                timeInterval: 10.0,
                target: self,
                selector: #selector(updateBlockedState),
                userInfo: nil,
                repeats: true
            )
            blockedMessage = blockedMessage(for: blockedTill)
            delegate?.presentWrongPasscodeAlert(with: blockedMessage, title: nil, buttonTitle: nil)
        } else {
            UserDefaultsHelper.blockedTill = nil
            blockedTimer?.invalidate()
            blockedTimer = nil
            delegate?.dismissWrongPasscodeAlert()
        }
    }
}

// MARK: - Presentation
extension PasscodeViewModel {
    var shouldShowTouchId: Bool {
        return purpose == .enter
    }

    var title: String {
        switch purpose {
        case .create: return l10n(.createPasscode)
        case .edit: return l10n(.yourCurrentPasscode)
        case .enter: return ""
        }
    }

    var wrongPasscodeLabelText: String {
        switch purpose {
        case .create, .edit: return l10n(.passcodeDontMatch)
        case .enter: return l10n(.wrongPasscode)
        }
    }
}

// MARK: - Actions
private extension PasscodeViewModel {
    func blockedMessage(for date: Date) -> String {
        let secondsLeft = Int(date.timeIntervalSinceNow)
        let minutesLeft = secondsLeft / 60 + 1
        let message = minutesLeft > 1 ? l10n(.wrongPasscode) : l10n(.wrongPasscodeSingular)
        return message.replacingOccurrences(of: "%{count}", with: "\(minutesLeft)")
    }

    @objc func updateBlockedState() {
        if let blockedTill = UserDefaultsHelper.blockedTill, Date() < blockedTill {
            blockedMessage = blockedMessage(for: blockedTill)
        } else {
            blockedTimer?.invalidate()
            blockedTimer = nil
            UserDefaultsHelper.blockedTill = nil
            delegate?.dismissWrongPasscodeAlert()
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
    }
}
