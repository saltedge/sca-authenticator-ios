//
//  SettingsCell.swift
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

enum SettingsCellType: Localizable {
    case language
    case passcode
    case biometrics
    case appVersion
    case terms
    case support
    case about

    var localizedLabel: String {
        switch self {
        case .language: return l10n(.language)
        case .passcode: return l10n(.passcode)
        case .biometrics: return BiometricsPresenter.biometricTypeText
        case .appVersion: return l10n(.applicationVersion)
        case .terms: return l10n(.terms)
        case .support: return l10n(.support)
        case .about: return l10n(.about)
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

final class SettingsCell: UITableViewCell, Dequeuable {

    private var biometricsSwitch: UISwitch {
        let toggler = UISwitch()
        toggler.addTarget(self, action: #selector(toggleBiometricsState(_:)), for: .valueChanged)
        toggler.onTintColor = .auth_blue
        toggler.isOn = PasscodeManager.isBiometricsEnabled
        return toggler
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    func set(with item: SettingsCellType) {
        textLabel?.text = item.localizedLabel
        if let detailsText = item.detailString {
            detailTextLabel?.text = detailsText
        }

        switch item {
        case .language:
            accessoryType = .disclosureIndicator
            detailTextLabel?.centerY(to: contentView)
            detailTextLabel?.right(to: contentView, offset: -10.0)
        case .passcode,
             .about: accessoryType = .disclosureIndicator
        case .biometrics: accessoryView = biometricsSwitch
        case .terms, .support: textLabel?.textColor = .auth_blue
        default: break
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func toggleBiometricsState(_ toggler: UISwitch) {
        if BiometricsHelper.biometryType == .none {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        } else {
            PasscodeManager.isBiometricsEnabled = toggler.isOn
        }
    }
}
