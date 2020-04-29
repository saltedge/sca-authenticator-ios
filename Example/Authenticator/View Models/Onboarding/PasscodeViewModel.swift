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

final class PasscodeViewModel {
    enum PasscodeViewMode {
        case create
        case edit
        case enter
    }

    var state: Observable<PasscodeViewModelState>

    private var purpose: PasscodeViewModel.PasscodeViewMode
    private var passcode = ""
    private var confirmationPasscode = ""

    init(purpose: PasscodeViewModel.PasscodeViewMode) {
        self.purpose = purpose
        self.state = Observable<PasscodeViewModelState>(purpose == .create ? .create(showLabel: false) : .check)
    }

    var shouldDismiss: Bool {
        return purpose == .enter
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
    }

    func switchToCreate(showLabel: Bool) {
        state.value = .create(showLabel: showLabel)

        passcode = ""
    }

    func switchToRepeat() {
        state.value = .repeat
    }
}

// MARK: - Presentation
extension PasscodeViewModel {
    var shouldShowTouchId: Bool {
        return purpose == .enter && PasscodeManager.isBiometricsEnabled
    }

    var title: String {
        switch purpose {
        case .create: return l10n(.createPasscode)
        case .edit: return l10n(.enterPasscode)
        case .enter:
            return PasscodeManager.isBiometricsEnabled ? BiometricsPresenter.passcodeDescriptionText : l10n(.enterPasscode)
        }
    }

    var wrongPasscodeLabelText: String {
        switch purpose {
        case .create, .edit: return l10n(.passcodeDontMatch)
        case .enter: return l10n(.wrongPasscode)
        }
    }
}
