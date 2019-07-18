//
//  AppSettings.swift
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

enum WebURLResourceType: String {
    case terms
}

enum EnvironmentSettingType: String {
    case rootURL
}

class AppSettings {
    static private let kStagingEnvironment = "STAGING"
    static private let kProductionEnvironment = "PRODUCTION"

    static var rootURL: URL { return URL(string: settingValueForType(.rootURL))! }

    // MARK: - Authenticator API
    static var termsURL: URL { return urlWithPathForType(.terms) }

    static var bundleId: String {
        guard let id = Bundle.authenticator_main.bundleIdentifier else { return "" }

        return id
    }

    static var supportEmail: String {
        guard let supportEmail = environmentSettings["support_email"] as? String else { return "" }

        return supportEmail
    }

    static var isNotInTestMode: Bool {
        return ProcessInfo().environment["SPECS"] == nil
    }

    static var fabricApiKey: String {
        if let apiKey = settingsDictionary["FabricApiKey"] as? String {
            return apiKey
        }

        return ""
    }

    static var environmentSettings: [String: Any] {
        guard let settings = settingsDictionary[environment] as? [String: Any] else { return [:] }

        return settings
    }

    static var versionAndBuildNumber: String {
        return "\(version) (\(buildNumber))"
    }

    private static var version: String {
        guard let version = Bundle.authenticator_main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return "No Version"
        }
        return version
    }

    private static var buildNumber: String {
        guard let buildNumber = Bundle.authenticator_main.object(forInfoDictionaryKey: "CFBundleVersion") as? String else {
            return "No Build Number"
        }
        return buildNumber
    }

    private static var environment: String {
        guard isNotInTestMode else { return kStagingEnvironment }

        #if STAGING
            return kStagingEnvironment
        #else
            return kProductionEnvironment
        #endif
    }

    static var isProduction: Bool {
        return environment == kProductionEnvironment
    }

    private static var settingsDictionary: NSDictionary {
        let path = Bundle.authenticator_main.path(
            forResource: isNotInTestMode ? "application" : "application.example", ofType: "plist"
        )!
        return NSDictionary(contentsOfFile: path)!
    }

    private static func urlWithPathForType(_ type: WebURLResourceType) -> URL {
        // swiftlint:disable:next force_cast
        let path = settingsDictionary[type.rawValue] as! String

        return rootURL.appendingPathComponent(path)
    }

    private static func settingValueForType(_ type: EnvironmentSettingType) -> String {
        guard let value = environmentSettings[type.rawValue] as? String else { return "" }

        return value
    }
}
