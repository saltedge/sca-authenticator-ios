//
//  ConnectionsCollector.swift
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
import SEAuthenticator

struct ConnectionsCollector {
    static var allConnectionsGuids: [String] {
        return allConnections.map { $0.guid }
    }

    static var allConnections: Results<Connection> {
        return RealmManager.defaultRealm.objects(Connection.self)
    }

    static var activeConnections: Results<Connection> {
        return self.where("\(#keyPath(Connection.status)) == %@", "active")
            .sorted(
                byKeyPath: #keyPath(Connection.createdAt),
                ascending: true
            )
    }

    static func activeConnections(by connectUrl: URL) -> [Connection] {
        return Array(activeConnections).filter { $0.baseUrl == connectUrl }
    }

    static var connectionNames: [String] {
        return allConnections.map { $0.name }
    }

    static func with(id: String) -> Connection? {
        return self.where("\(#keyPath(Connection.id)) == %@", id).first
    }
    
    static func active(by id: String) -> Connection? {
        return self.where("\(#keyPath(Connection.id)) == %@ AND \(#keyPath(Connection.status)) == %@", id, "active").first
    }

    static func `where`(_ format: String, _ args: Any...) -> Results<Connection> {
        return ConnectionsCollector.allConnections.filter(NSPredicate(format: format, argumentArray: args))
            .sorted(byKeyPath: #keyPath(Connection.createdAt))
    }
}
