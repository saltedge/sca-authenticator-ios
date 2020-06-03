//
//  PasscodeManger.swift
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

import Foundation
import LocalAuthentication

struct PasscodeManager {
    static func set(passcode: String) {
        KeychainHelper.setObject(passcode, forKey: KeychainKeys.passcode.rawValue)
    }

    static var hasPasscode: Bool {
        return !current.isEmpty
    }

    static var isBiometricsEnabled: Bool {
        set {
            UserDefaultsHelper.isBiometricsEnabled = newValue
        }
        get {
            return UserDefaultsHelper.isBiometricsEnabled
        }
    }

    static func useBiometrics(reasonString: String,
                              onSuccess: (() -> ())?,
                              onFailure: ((Error) -> ())?) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reasonString,
                reply: { success, evaluateError in
                    if success {
                        UserDefaultsHelper.isBiometricsEnabled = true
                        DispatchQueue.main.async { onSuccess?() }
                    } else {
                        guard let evError = evaluateError, evError._code != LAError.userCancel.rawValue else { return }

                        UserDefaultsHelper.isBiometricsEnabled = false

                        DispatchQueue.main.async { onFailure?(evError) }
                    }
                }
            )
        } else {
            UserDefaultsHelper.isBiometricsEnabled = false
            DispatchQueue.main.async {
                onFailure?(LAError(LAError.biometryNotAvailable))
            }
        }
    }

    static var current: String {
        guard let passcode = KeychainHelper.object(forKey: KeychainKeys.passcode.rawValue) else { return "" }

        return passcode
    }

    static func remove() {
        KeychainHelper.deleteObject(forKey: KeychainKeys.passcode.rawValue)
    }
}

extension Error {
    var isBiometryLockout: Bool {
        return self._code == LAError.biometryLockout.rawValue
    }
}
