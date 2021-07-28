//
//  SEConsentData
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

public struct SEConsentData {
    public var id: String?
    public var userId: String?
    public let connectionId: String
    public let tppName: String
    public let consentType: String
    public let accounts: [SEAccount]
    public let sharedData: SEConsentSharedData?
    public let createdAt: Date
    public let expiresAt: Date

    public init?(_ dictionary: [String: Any], _ entityId: String?, _ connectionId: String) {
        if let tppName = dictionary[SENetKeys.tppName] as? String,
            let consentType = dictionary[SENetKeys.consentType] as? String,
            let accountsObjects = dictionary[SENetKeys.accounts] as? [[String: Any]],
            let createdAt = (dictionary[SENetKeys.createdAt] as? String)?.iso8601date,
            let expiresAt = (dictionary[SENetKeys.expiresAt] as? String)?.iso8601date {
            self.tppName = tppName
            self.consentType = consentType
            self.createdAt = createdAt
            self.expiresAt = expiresAt

            let accounts = accountsObjects.compactMap { SEAccount($0) }
            self.accounts = accounts

            self.sharedData = SEConsentSharedData((dictionary[SENetKeys.sharedData] as? [String: Bool]))

            self.connectionId = connectionId

            if let userId = dictionary[SENetKeys.userId] as? String {
                self.userId = userId
            }
            if let entityId = entityId {
                self.id = entityId
            } else if let id = dictionary[SENetKeys.id] as? String {
                self.id = id
            }
        } else {
            return nil
        }
    }
}

public struct SEAccount {
    public let name: String
    public let accountNumber: String?
    public let sortCode: String?
    public let iban: String?
    
    public init?(_ dictionary: [String: Any]) {
        if let name = dictionary[SENetKeys.name] as? String {
            self.name = name
            self.accountNumber = dictionary[SENetKeys.accountNumber] as? String
            self.sortCode = dictionary[SENetKeys.sortCode] as? String
            self.iban = dictionary[SENetKeys.iban] as? String
        } else {
            return nil
        }
    }
}

public struct SEConsentSharedData {
    public let balance: Bool?
    public let transactions: Bool?
    
    public init?(_ dictionary: [String: Bool]?) {
        guard let unwrappedDictionary = dictionary else { return nil }

        self.balance = unwrappedDictionary[SENetKeys.balance]
        self.transactions = unwrappedDictionary[SENetKeys.transactions]
    }
}

extension SEConsentData: Equatable {
    public static func == (lhs: SEConsentData, rhs: SEConsentData) -> Bool {
        return lhs.id == rhs.id &&
            lhs.userId == rhs.userId &&
            lhs.connectionId == rhs.connectionId &&
            lhs.tppName == rhs.tppName &&
            lhs.consentType == rhs.consentType &&
            lhs.accounts == rhs.accounts &&
            lhs.createdAt == rhs.createdAt &&
            lhs.expiresAt == rhs.expiresAt
    }
}

extension SEAccount: Equatable {
    public static func == (lhs: SEAccount, rhs: SEAccount) -> Bool {
        return lhs.name == rhs.name &&
            lhs.accountNumber == rhs.accountNumber &&
            lhs.sortCode == rhs.sortCode &&
            lhs.iban == rhs.iban
    }
}

extension SEConsentSharedData: Equatable {
    public static func == (lhs: SEConsentSharedData, rhs: SEConsentSharedData) -> Bool {
        return lhs.balance == rhs.balance && lhs.transactions == rhs.transactions
    }
}

