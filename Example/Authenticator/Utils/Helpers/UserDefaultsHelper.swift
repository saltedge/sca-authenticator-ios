//
//  UserDefaultsHelper.swift
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

private enum DefaultsKeys: String {
    case didShowOnboarding
    case isBiometricsEnabled
    case applicationLanguage
    case blockedTill
    case wrongPasscodeAttempts
    case pushToken
}

struct UserDefaultsHelper {
    private static let suiteName = "\(AppSettings.bundleId).defaults"

    static var applicationLanguage: String {
        get {
            if let appLanguage = defaults.string(forKey: DefaultsKeys.applicationLanguage.rawValue) {
                return appLanguage
            }

            return "en"
        }
        set {
            let languageCode = LocalizationHelper.languageCode(from: newValue)
            defaults.set(languageCode, forKey: DefaultsKeys.applicationLanguage.rawValue)
            defaults.synchronize()
        }
    }

    static var didShowOnboarding: Bool {
        get {
            return defaults.bool(forKey: DefaultsKeys.didShowOnboarding.rawValue)
        }
        set {
            defaults.set(newValue, forKey: DefaultsKeys.didShowOnboarding.rawValue)
            defaults.synchronize()
        }
    }

    static var isBiometricsEnabled: Bool {
        get {
            return defaults.bool(forKey: DefaultsKeys.isBiometricsEnabled.rawValue)
        }
        set {
            defaults.set(newValue, forKey: DefaultsKeys.isBiometricsEnabled.rawValue)
            defaults.synchronize()
        }
    }

    static var blockedTill: Date? {
        get {
            return defaults.object(forKey: DefaultsKeys.blockedTill.rawValue) as? Date
        }
        set {
            defaults.set(newValue, forKey: DefaultsKeys.blockedTill.rawValue)
            defaults.synchronize()
        }
    }

    static var wrongPasscodeAttempts: Int {
        get {
            return defaults.integer(forKey: DefaultsKeys.wrongPasscodeAttempts.rawValue)
        }
        set {
            defaults.set(newValue, forKey: DefaultsKeys.wrongPasscodeAttempts.rawValue)
            defaults.synchronize()
        }
    }

    static var pushToken: String {
        get {
            return defaults.string(forKey: DefaultsKeys.pushToken.rawValue) ?? ""
        }
        set {
            defaults.set(newValue, forKey: DefaultsKeys.pushToken.rawValue)
            defaults.synchronize()
        }
    }

    static func clearDefaults() {
        for key in defaults.dictionaryRepresentation().keys {
            defaults.removeObject(forKey: key)
        }

        guard let identifier = Bundle.authenticator_main.bundleIdentifier else {
            defaults.synchronize()
            return
        }

        defaults.removePersistentDomain(forName: identifier)
        defaults.synchronize()
    }

    private static var defaults: UserDefaults {
        return UserDefaults(suiteName: suiteName)!
    }
}
