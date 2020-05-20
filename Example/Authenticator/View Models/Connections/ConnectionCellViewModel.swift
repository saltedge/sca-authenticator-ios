//
//  ConnectionViewModel
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

import UIKit

@dynamicMemberLookup
class ConnectionCellViewModel {
    private let connection: Connection

    var connectionStatus = Observable<ConnectionStatus>(.active)
    var connectionName: String {
        return connection.name
    }
    var description: String {
        return connectionStatus.value == .inactive
            ? l10n(.inactiveConnection)
            : "\(l10n(.connectedOn)) \(connection.createdAt.dayMonthYearWithTimeString)"
    }
    var descriptionColor: UIColor {
        return connectionStatus.value == .inactive
            ? .connectionDescriptionError
            : .dark60
    }

    init(connection: Connection) {
        self.connection = connection
        self.connectionStatus.value = ConnectionStatus(rawValue: connection.status)!
    }

    subscript<T>(dynamicMember keyPath: KeyPath<Connection, T>) -> T {
        return connection[keyPath: keyPath]
    }
}

private extension ConnectionCellViewModel {
    static func dayMonthYearWithTimeDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

private extension Date {
    var dayMonthYearWithTimeString: String {
        return ConnectionCellViewModel.dayMonthYearWithTimeDateFormatter().string(from: self)
    }
}
