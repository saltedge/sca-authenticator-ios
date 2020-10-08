//
//  LocalizationHelper.swift
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

struct Language {
    var displayName: String
    var code: String
}

struct LocalizationHelper {
    static var stringsDictionary: [String: String]?

    static var availableLocalizations: [Language] {
        let paths = Bundle.authenticator_main.paths(forResourcesOfType: "lproj", inDirectory: nil)
        let languages: [Language] = paths.compactMap { path in
            if let code = URL(string: path)?.deletingPathExtension().lastPathComponent,
                let language = languageDisplayName(from: code) {
                return Language(displayName: language, code: code)
            }
            return nil
        }

        return languages
    }

    static func languageDisplayNamesForAvailableLocalizations() -> [String] {
        return availableLocalizations.map { $0.displayName }
    }

    static func languageCode(from displayName: String) -> String? {
        if let filtered = availableLocalizations.filter({ $0.displayName == displayName }).first {
            return filtered.code
        }

        return nil
    }

    static func languageDisplayName(from code: String) -> String? {
        let identifier = NSLocale(localeIdentifier: code)
        guard let displayName = identifier.displayName(forKey: .identifier, value: code) else { return nil }

        return displayName.capitalized
    }

    static func localizedString(for key: String) -> String? {
        let language = UserDefaultsHelper.applicationLanguage
        if stringsDictionary == nil {
            guard let path = Bundle.authenticator_main.path(
                forResource: "Authenticator",
                ofType: "strings",
                inDirectory: nil,
                forLocalization: language
            ) else { return "" }

            stringsDictionary = NSDictionary(contentsOfFile: path) as? [String: String]
        }

        return stringsDictionary?[key]
    }
}
