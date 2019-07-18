//
//  BiometricsPresenter.swift
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

struct BiometricsPresenter {
    static var onboardingImage: UIImage? {
        guard BiometricsHelper.biometricsAvailable else { return UIImage() }

        return BiometricsHelper.biometryType == .faceID ? UIImage(named: "Face ID") : UIImage(named: "Touch ID")
    }

    static var keyboardImage: UIImage? {
        guard BiometricsHelper.biometricsAvailable else { return UIImage() }

        return BiometricsHelper.biometryType == .faceID ? UIImage(named: "Face ID Passcode") : UIImage(named: "Touch ID Passcode")
    }

    static var biometricTypeText: String {
        switch BiometricsHelper.biometryType {
        case .faceID: return l10n(.faceID)
        case .touchID: return l10n(.touchID)
        default: return l10n(.enableBiometrics)
        }
    }

    static var usageDescription: String {
        switch BiometricsHelper.biometryType {
        case .faceID: return l10n(.allowFaceIdDescription)
        case .touchID: return l10n(.allowTouchIdDescription)
        default: return l10n(.notEnabledBiometricsMessage)
        }
    }

    static var allowText: String {
        switch BiometricsHelper.biometryType {
        case .faceID: return l10n(.allowFaceID)
        case .touchID: return l10n(.allowTouchID)
        default: return l10n(.goToSettings)
        }
    }

    static var passcodeDescriptionText: String {
        switch BiometricsHelper.biometryType {
        case .faceID: return l10n(.enterPasscodeOrUseFaceID)
        case .touchID: return l10n(.enterPasscodeOrUseTouchID)
        default: return l10n(.enterPasscode)
        }
    }
}
