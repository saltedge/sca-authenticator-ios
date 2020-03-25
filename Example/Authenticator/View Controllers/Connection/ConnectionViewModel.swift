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
import SEAuthenticator

class ConnectionViewModel {
    private let connection: Connection

    let connectionName: String
    let connectionImageUrl: URL?
    let description: String
    let supportEmail: String
    var descriptionColor: UIColor = .auth_gray

    init(connection: Connection) {
        self.connection = connection
        self.connectionName = connection.name
        self.supportEmail = connection.supportEmail
        self.connectionImageUrl = connection.logoUrl

        let inactiveDescription = l10n(.inactiveConnection)
        let activeDescription = "\(l10n(.connectedOn)) \(connection.createdAt.dayMonthYearWithTimeString)"

        self.description = connection.status == ConnectionStatus.inactive.rawValue ? inactiveDescription : activeDescription
        self.descriptionColor = connection.status == ConnectionStatus.inactive.rawValue ? .auth_red : .auth_gray
    }

    func update(with text: String) {
        try? RealmManager.performRealmWriteTransaction {
            connection.name = text
        }
    }

    func remove() {
        let expiresAt = Date().addingTimeInterval(5.0 * 60.0).utcSeconds

        ConnectionsInteractor.revoke(connection, expiresAt: expiresAt)
        SECryptoHelper.deleteKeyPair(with: SETagHelper.create(for: connection.guid))
        ConnectionRepository.delete(connection)
    }
}

private extension ConnectionViewModel {
    static func dayMonthYearWithTimeDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

private extension Date {
    var dayMonthYearWithTimeString: String {
        return ConnectionViewModel.dayMonthYearWithTimeDateFormatter().string(from: self)
    }
}
