//
//  SENetKeys.swift
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2021 Salt Edge Inc.
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

public struct SENetKeys {
    public static let aps = "aps"

    public static let data = "data"
    public static let id = "id"
    public static let name = "name"
    public static let code = "code"
    public static let logoUrl = "logo_url"
    public static let supportEmail = "support_email"
    public static let version = "version"
    public static let geolocationRequired = "geolocation_required"

    public static let configuration = "configuration"
    public static let connectQuery = "connect_query"
    public static let connectUrl = "connect_url"

    public static let title = "title"
    public static let description = "description"
    public static let message = "message"

    public static let success = "success"

    public static let accessToken = "access_token"

    public static let createdAt = "created_at"
    public static let expiresAt = "expires_at"
    public static let redirectUrl = "redirect_url"

    public static let key = "key"
    public static let iv = "iv"

    public static let authorizationId = "authorization_id"
    public static let authorizationCode = "authorization_code"

    public static let connectionId = "connection_id"
    public static let algorithm = "algorithm"
    
    public static let consentId = "consent_id"

    public static let errorClass = "error_class"
    public static let errorMessage = "error_message"

    public static let userId = "user_id"
    public static let consentManagement = "consent_management"
    public static let tppName = "tpp_name"
    public static let consentType = "consent_type"
    public static let accounts = "accounts"
    public static let sharedData = "shared_data"
    public static let accountNumber = "account_number"
    public static let sortCode = "sort_code"
    public static let iban = "iban"
    public static let balance = "balance"
    public static let transactions = "transactions"
}
