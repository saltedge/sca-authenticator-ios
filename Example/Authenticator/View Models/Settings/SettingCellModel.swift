//
//  SettingCellModel.swift
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

enum SettingCellModel: Localizable {
    case language
    case passcode
    case appVersion
    case terms
    case support
    case about
    case licenses
    case clearData

    var localizedLabel: String {
        switch self {
        case .language: return l10n(.language)
        case .passcode: return l10n(.changePasscode)
        case .appVersion: return l10n(.applicationVersion)
        case .terms: return l10n(.terms)
        case .support: return l10n(.reportABug)
        case .about: return l10n(.about)
        case .licenses: return l10n(.licenses)
        case .clearData: return l10n(.clearAllData)
        }
    }

    var icon: UIImage? {
        switch self {
        case .language: return UIImage(named: "settingsLanguage", in: .authenticator_main, compatibleWith: nil)
        case .passcode: return UIImage(named: "settingsPasscode", in: .authenticator_main, compatibleWith: nil)
        case .about: return UIImage(named: "settingsAbout", in: .authenticator_main, compatibleWith: nil)
        case .support: return UIImage(named: "settingsSupport", in: .authenticator_main, compatibleWith: nil)
        case .clearData: return UIImage(named: "settingsClear", in: .authenticator_main, compatibleWith: nil)
        default: return nil
        }
    }

    var detailString: String? {
        switch self {
        case .language: return LocalizationHelper.languageDisplayName(from: UserDefaultsHelper.applicationLanguage)
        case .appVersion: return AppSettings.versionAndBuildNumber
        default: return nil
        }
    }
}
