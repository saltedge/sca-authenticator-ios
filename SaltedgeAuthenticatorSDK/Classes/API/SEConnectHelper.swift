//
//  SEConnectHelper.swift
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
import SEAuthenticatorCore

public struct SEConnectHelper {
    public static func isValid(deepLinkUrl url: URL) -> Bool {
        return сonfiguration(from: url) != nil || isValidAction(deepLinkUrl: url)
    }

    public static func isValidAction(deepLinkUrl url: URL) -> Bool {
        return actionGuid(from: url) != nil && connectUrl(from: url) != nil
    }

    public static func returnToUrl(from url: URL) -> URL? {
        guard let query = url.queryItem(for: "return_to") else { return nil }

        return URL(string: query)
    }

    public static func connectUrl(from url: URL) -> URL? {
        guard let query = url.queryItem(for: "connect_url") else { return nil }

        return URL(string: query)
    }

    public static func actionGuid(from url: URL) -> String? {
        guard let query = url.queryItem(for: "action_uuid") else { return nil }

        return query
    }

    public static func сonfiguration(from url: URL) -> URL? {
        guard let query = url.queryItem(for: SENetKeys.configuration) else { return nil }

        return URL(string: query)
    }

    public static func connectQuery(from url: URL) -> String? {
        guard let query = url.queryItem(for: SENetKeys.connectQuery) else { return nil }

        return query
    }
}
