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
    case normal

    static func == (lhs: PasscodeViewModelState, rhs: PasscodeViewModelState) -> Bool {
        switch (lhs, rhs) {
        case (.normal, .normal),
             (.wrongPasscode, .wrongPasscode),
             (.switchToCreate, .switchToCreate),
             (.switchToRepeat, .switchToRepeat),
             (.completedStage, .completedStage):
            return true
        default: return false
        }
    }
}

class PasscodeViewModel {
    var state = Observable<PasscodeViewModelState>(.normal)

    private var purpose: PasscodeView.Purpose
    private var stage: PasscodeView.Stage = .first
    private var passcode = ""
    private var confirmationPasscode = ""

    init(purpose: PasscodeView.Purpose) {
        self.purpose = purpose
    }

    var title: String {
        switch purpose {
        case .create: return l10n(.createPasscode)
        case .edit: return l10n(.enterPasscode)
        case .enter:
            return PasscodeManager.isBiometricsEnabled ? BiometricsPresenter.passcodeDescriptionText : l10n(.enterPasscode)
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

//        guard purpose == .create else { return checkPassword() }
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

//        delegate?.passwordCorrect()
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
