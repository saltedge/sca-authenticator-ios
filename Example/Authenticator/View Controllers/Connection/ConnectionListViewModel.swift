//
//  ConnectionListViewModel
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
import RealmSwift
import SEAuthenticator

class ConnectionListViewModel {
    typealias OnDataChangeClosure = () -> ()

    private let connections = ConnectionsCollector.allConnections.sorted(
        byKeyPath: #keyPath(Connection.createdAt),
        ascending: true
    )

    private var onDataChange: OnDataChangeClosure?
    private var connectionsNotificationToken: NotificationToken?

    init(onDataChange: OnDataChangeClosure? = nil) {
        self.onDataChange = onDataChange

        connectionsNotificationToken = connections.observe { [weak self] _ in
            guard let onDataChange = self?.onDataChange else { return }

            onDataChange()
        }
    }

    func count() -> Int {
        return connections.count
    }

    func item(for indexPath: IndexPath) -> Connection? {
        if indexPath.row == 0 && connections.indices.contains(indexPath.section) {
            return connections[indexPath.section]
        }
        return nil
    }

    func cellViewModel(at indexPath: IndexPath) -> ConnectionCellViewModel {
        return ConnectionCellViewModel(connection: item(for: indexPath)!)
    }

    func connectionId(at indexPath: IndexPath) -> String? {
        guard let connection = item(for: indexPath) else { return nil }

        return connection.id
    }

    func remove(at indexPath: IndexPath) {
        guard let connection = item(for: indexPath) else { return }

        let expiresAt = Date().addingTimeInterval(5.0 * 60.0).utcSeconds

        ConnectionsInteractor.revoke(connection, expiresAt: expiresAt)
        SECryptoHelper.deleteKeyPair(with: SETagHelper.create(for: connection.guid))
        ConnectionRepository.delete(connection)
    }

    deinit {
        connectionsNotificationToken?.invalidate()
    }
}
