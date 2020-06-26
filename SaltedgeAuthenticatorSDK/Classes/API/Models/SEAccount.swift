//
//  SEAccount.swift
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

import Foundation

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

extension SEAccount: Equatable {
    public static func == (lhs: SEAccount, rhs: SEAccount) -> Bool {
        return lhs.name == rhs.name &&
            lhs.accountNumber == rhs.accountNumber &&
            lhs.sortCode == rhs.sortCode &&
            lhs.iban == rhs.iban
    }
}

