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

class PasscodeViewModel {
    var state: Observable<PasscodeViewModelState>

    private var purpose: PasscodeView.Purpose
    private var passcode = ""
    private var confirmationPasscode = ""

    init(purpose: PasscodeView.Purpose) {
        self.purpose = purpose
        self.state = Observable<PasscodeViewModelState>(purpose == .create ? .create(showLabel: false) : .check)
    }

    var shouldShowTouchId: Bool {
        return purpose == .enter && PasscodeManager.isBiometricsEnabled
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

    func didInput(digit: String, symbols: [PasscodeSymbolView]) {
        if passcodeToFill.count < 3 {
            passcodeToFill.append(digit)
            symbols[passcodeToFill.count - 1].animateCircle()
        } else {
            passcodeToFill.append(digit)
            if symbols.indices.contains(passcodeToFill.count - 1) {
                symbols[passcodeToFill.count - 1].animateCircle()

                switch state.value {
                case .check: checkPassword()
                case .create: switchToRepeat()
                case .repeat: comparePasswords()
                default: break
                }
            }
        }
    }

    func clearPressed(symbols: [PasscodeSymbolView]) {
        if passcodeToFill.count != 0 {
            passcodeToFill = String(passcodeToFill.dropLast(1))
            symbols[passcodeToFill.count].animateEmpty()
        }
    }

    func checkPassword() {
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

    func comparePasswords() {
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

// MARK: - Setup
extension PasscodeViewModel {
    func setupLogo(for imageView: UIImageView) {
        guard purpose == .enter else { return }

        imageView.image = #imageLiteral(resourceName: "Logo")
        imageView.contentMode = .scaleAspectFit
    }
}
