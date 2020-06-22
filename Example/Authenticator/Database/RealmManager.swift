//
//  RealmManager.swift
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

final class RealmManager {
    private static var realmConfiguration: Realm.Configuration?

    static var defaultRealm: Realm {
        return constructRealm()
    }

    static var dbKey: String? {
        let generateKey: () -> (String) = {
            var key = (UUID().uuidString + UUID().uuidString)
            key = key.replacingOccurrences(of: "-", with: "")
            return key
        }

        guard AppSettings.isNotInTestMode else { return generateKey() }

        if let key = KeychainHelper.object(forKey: KeychainKeys.db.rawValue) {
            return key
        }
        let key = generateKey()

        KeychainHelper.setObject(key, forKey: KeychainKeys.db.rawValue)

        return key
    }

    private static func constructRealm() -> Realm {
        guard AppSettings.isNotInTestMode else {
            return try! Realm(configuration: migratedConfiguration) // swiftlint:disable:this force_try
        }

        if realmConfiguration == nil {
            setupRealmConfiguration()
        }
        do {
            return try Realm(configuration: realmConfiguration!)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    private static var migratedConfiguration: Realm.Configuration {
        var config = Realm.Configuration.defaultConfiguration
        config.schemaVersion = UInt64(RealmMigrationManager.schemaVersion)
        config.migrationBlock = RealmMigrationManager.migrationBlock
        return config
    }

    private static func setupRealmConfiguration() {
        var config = migratedConfiguration
        guard let key = dbKey else {
            fatalError("Realm cannot be initialized")
        }
        config.encryptionKey = key.data(using: .utf8)
        realmConfiguration = config
    }

    static func insideRealmWriteTransaction(block: (Realm) throws -> ()) -> Bool {
        let realm = self.defaultRealm
        do {
            try block(realm)
            return true
        } catch {
            realm.cancelWrite()
            return false
        }
    }

    static func performRealmWriteTransaction(block: () throws -> ()) throws {
        var rethrowable: Error?
        do {
            try self.defaultRealm.write {
                do {
                    try block()
                } catch let error {
                    self.defaultRealm.cancelWrite()
                    rethrowable = error
                }
            }
        } catch let error {
            rethrowable = error
        }
        if let error = rethrowable {
            throw(error)
        }
    }

    static func deleteAll() {
        do {
            try self.defaultRealm.write {
                self.defaultRealm.deleteAll()
            }
        } catch let error {
            self.defaultRealm.cancelWrite()
            fatalError("Error occured when deleting all from Realm error: \(error)")
        }
    }
}
