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
    case didInputDigit
    case wrongPasscode
    case switchToCreate
    case switchToRepeat
    case completedStage
    case correctPasscode
    case normal

    static func == (lhs: PasscodeViewModelState, rhs: PasscodeViewModelState) -> Bool {
        switch (lhs, rhs) {
        case (.normal, .normal),
             (.wrongPasscode, .wrongPasscode),
             (.switchToCreate, .switchToCreate),
             (.switchToRepeat, .switchToRepeat),
             (.completedStage, .completedStage),
             (.correctPasscode, .correctPasscode):
            return true
        default: return false
        }
    }
}

class PasscodeViewModel {
    enum Stage {
        case first
        case second
    }

    var state = Observable<PasscodeViewModelState>(.normal)

    private var purpose: PasscodeView.Purpose
    private var stage: Stage = .first
    private var passcode = ""
    private var confirmationPasscode = ""

    init(purpose: PasscodeView.Purpose) {
        self.purpose = purpose
    }

    var shouldShowTouchId: Bool {
        return purpose == .enter && PasscodeManager.isBiometricsEnabled
    }

    var passcodeToFill: String {
        get {
            return stage == .first ? passcode : confirmationPasscode
        }
        set {
            if stage == .first {
                passcode = newValue
            } else {
                confirmationPasscode = newValue
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

    func didInput(digit: String, symbols: [PasscodeSymbolView]) {
        if passcodeToFill.count < 3 {
            passcodeToFill.append(digit)
            symbols[passcodeToFill.count - 1].animateCircle()
        } else {
            passcodeToFill.append(digit)
            if symbols.indices.contains(passcodeToFill.count - 1) {
                symbols[passcodeToFill.count - 1].animateCircle()
                if purpose == .enter {
                    checkPassword()
                } else {
                    after(0.1) { self.stageCompleted() }
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

    func wrongPasscode() {
        state.value = .wrongPasscode

        passcode = ""
        confirmationPasscode = ""
    }

    func switchedToCreate() {
        state.value = .switchToCreate
        stage = .first
        passcode = ""
    }

    func stageCompleted() {
        state.value = .completedStage

        stage == .first ? switchToRepeat() : comparePasswords()
    }

    func switchToRepeat() {
        state.value = .switchToRepeat

        stage = .second
    }

    func checkPassword() {
        guard passcode == PasscodeManager.current else {
            wrongPasscode()
            return
        }

        state.value = .correctPasscode
    }

    func comparePasswords() {
        guard passcode == confirmationPasscode else {
            wrongPasscode()
            switchedToCreate()
            return
        }

        PasscodeManager.set(passcode: passcode)

        state.value = .correctPasscode
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
