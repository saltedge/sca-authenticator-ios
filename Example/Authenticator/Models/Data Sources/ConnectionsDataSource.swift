//
//  ConnectionsDataSource.swift
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
import RealmSwift

final class ConnectionsDataSource {
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

    deinit {
        connectionsNotificationToken?.invalidate()
    }

    var sections: Int {
        return connections.count
    }

    func rows(for section: Int) -> Int {
        if connections.indices.contains(section) {
            return 1
        }
        return 0
    }

    func height(for section: Int) -> CGFloat {
        return 86.0
    }

    func item(for indexPath: IndexPath) -> Connection? {
        if indexPath.row == 0 && connections.indices.contains(indexPath.section) {
            return connections[indexPath.section]
        }
        return nil
    }

    var hasDataToShow: Bool {
        return connections.count > 0
    }

    func cell(for indexPath: IndexPath) -> ConnectionCell {
        let connection = connections[indexPath.section]
        let cell = ConnectionCell()

        let inactiveDescription = l10n(.inactiveConnection)
        let activeDescription = "\(l10n(.connectedOn)) \(connection.createdAt.dayMonthYearWithTimeString)"
        let description = connection.status == ConnectionStatus.inactive.rawValue ? inactiveDescription : activeDescription

        cell.set(
            bankName: connection.name,
            description: description,
            descriptionColor: connection.status == ConnectionStatus.inactive.rawValue ? .auth_red : .auth_gray,
            imageUrl: connection.logoUrl
        )

        return cell
    }
}

private extension ConnectionsDataSource {
    static func dayMonthYearWithTimeDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

private extension Date {
    var dayMonthYearWithTimeString: String {
        return ConnectionsDataSource.dayMonthYearWithTimeDateFormatter().string(from: self)
    }
}
