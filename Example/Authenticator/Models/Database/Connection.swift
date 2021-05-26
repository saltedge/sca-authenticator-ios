//
//  Connection.swift
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
import RealmSwift

enum ConnectionStatus: String {
    case active
    case inactive
}

@objcMembers final class Connection: Object {
    dynamic var id: String = ""
    dynamic var guid: String = UUID().uuidString
    dynamic var name: String = ""
    dynamic var code: String = ""
    dynamic var baseUrlString: String = ""
    dynamic var logoUrlString: String = ""
    dynamic var accessToken: String = ""
    dynamic var status: String = ConnectionStatus.inactive.rawValue
    dynamic var supportEmail: String = ""
    dynamic let geolocationRequired = RealmOptional<Bool>()
    dynamic var createdAt: Date = Date()
    dynamic var updatedAt: Date = Date()

    dynamic var providerId: Int?
    dynamic var publicKey: String = ""
    dynamic var apiVersion: String = "1"

    override static func primaryKey() -> String? {
        return #keyPath(Connection.guid)
    }
}

extension Connection {
    var baseUrl: URL? {
        return URL(string: baseUrlString)
    }

    var logoUrl: URL? {
        return URL(string: logoUrlString)
    }

    var isManaged: Bool {
        return realm != nil
    }
}
