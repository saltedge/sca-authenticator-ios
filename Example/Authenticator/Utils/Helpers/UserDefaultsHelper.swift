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
        set {
            let languageCode = LocalizationHelper.languageCode(from: newValue)
            defaults.set(languageCode, forKey: DefaultsKeys.applicationLanguage.rawValue)
            defaults.synchronize()
        }
        get {
            if let appLanguage = defaults.string(forKey: DefaultsKeys.applicationLanguage.rawValue) {
                return appLanguage
            }

            return "en"
        }
    }

    static var didShowOnboarding: Bool {
        set {
            defaults.set(newValue, forKey: DefaultsKeys.didShowOnboarding.rawValue)
            defaults.synchronize()
        }
        get {
            return defaults.bool(forKey: DefaultsKeys.didShowOnboarding.rawValue)
        }
    }

    static var isBiometricsEnabled: Bool {
        set {
            defaults.set(newValue, forKey: DefaultsKeys.isBiometricsEnabled.rawValue)
            defaults.synchronize()
        }
        get {
            return defaults.bool(forKey: DefaultsKeys.isBiometricsEnabled.rawValue)
        }
    }

    static var blockedTill: Date? {
        set {
            defaults.set(newValue, forKey: DefaultsKeys.blockedTill.rawValue)
            defaults.synchronize()
        }
        get {
            return defaults.object(forKey: DefaultsKeys.blockedTill.rawValue) as? Date
        }
    }

    static var wrongPasscodeAttempts: Int {
        set {
            defaults.set(newValue, forKey: DefaultsKeys.wrongPasscodeAttempts.rawValue)
            defaults.synchronize()
        }
        get {
            return defaults.integer(forKey: DefaultsKeys.wrongPasscodeAttempts.rawValue)
        }
    }

    static var pushToken: String {
        set {
            defaults.set(newValue, forKey: DefaultsKeys.pushToken.rawValue)
            defaults.synchronize()
        }
        get {
            return defaults.string(forKey: DefaultsKeys.pushToken.rawValue) ?? ""
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
