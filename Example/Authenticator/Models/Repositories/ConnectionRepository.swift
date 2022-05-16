//
//  ConnectionRepository.swift
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
import SEAuthenticatorCore

struct ConnectionRepository {
    @discardableResult
    static func setAccessTokenAndActive(_ connection: Connection, accessToken token: String?) -> Bool {
        guard let token = token else { return false }

        var result = false
        if connection.isManaged {
            try? RealmManager.performRealmWriteTransaction {
                connection.accessToken = token
                connection.status = ConnectionStatus.active.rawValue
                result = true
            }
        } else {
            connection.accessToken = token
            connection.status = ConnectionStatus.active.rawValue
            result = true
        }

        return result
    }

    @discardableResult
    static func updateName(_ connection: Connection, name: String) -> Bool {
        var result = false
        try? RealmManager.performRealmWriteTransaction {
            connection.name = name
            result = true
        }
        return result
    }

    @discardableResult
    static func setInactive(_ connection: Connection) -> Bool {
        var result = false
        try? RealmManager.performRealmWriteTransaction {
            connection.status = ConnectionStatus.inactive.rawValue
            result = true
        }
        return result
    }

    @discardableResult
    static func save(_ object: Connection) -> Bool {
        var result = false
        try? RealmManager.performRealmWriteTransaction {
            result = RealmManager.insideRealmWriteTransaction { realm in
                realm.add(object, update: .all)
            }
        }
        return result
    }

    @discardableResult
    static func delete(_ object: Connection) -> Bool {
        var result = false
        try? RealmManager.performRealmWriteTransaction {
            result = RealmManager.insideRealmWriteTransaction { realm in
                realm.delete(object)
            }
        }
        return result
    }

    @discardableResult
    static func deleteAllConnections() -> Bool {
        var result = false
        try? RealmManager.performRealmWriteTransaction {
            result = RealmManager.insideRealmWriteTransaction { realm in
                realm.delete(realm.objects(Connection.self))
            }
        }
        return result
    }
}
