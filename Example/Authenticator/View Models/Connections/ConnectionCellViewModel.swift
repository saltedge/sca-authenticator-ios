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

protocol ConnectionCellEventsDelegate: class {
    func renamePressed(id: String)
    func supportPressed(email: String)
    func deletePressed(id: String, showConfirmation: Bool)
    func reconnectPreseed(id: String)
}

@dynamicMemberLookup
class ConnectionCellViewModel {
    private let connection: Connection

    weak var delegate: ConnectionCellEventsDelegate?

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
            ? .redAlert
            : .dark60
    }

    init(connection: Connection) {
        self.connection = connection
        self.connectionStatus.value = ConnectionStatus(rawValue: connection.status)!
    }

    subscript<T>(dynamicMember keyPath: KeyPath<Connection, T>) -> T {
        return connection[keyPath: keyPath]
    }

    @available(iOS 13.0, *)
    var contextMenuConfiguration: UIContextMenuConfiguration {
        let configuration = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { [weak self] _ -> UIMenu? in
            guard let strongSelf = self else { return nil }

            let rename = UIAction(title: l10n(.rename), image: UIImage(systemName: "square.and.pencil")) { _ in
                strongSelf.delegate?.renamePressed(id: strongSelf.connection.id)
            }
            let support = UIAction(title: l10n(.contactSupport), image: UIImage(systemName: "envelope")) { _ in
                strongSelf.delegate?.supportPressed(email: strongSelf.connection.supportEmail)
            }
            let delete = UIAction(title: l10n(.delete), image: UIImage(systemName: "trash")) { _ in
                strongSelf.delegate?.deletePressed(id: strongSelf.connection.id, showConfirmation: true)
            }

            var actions: [UIAction] = [rename, support, delete]

            if self?.connection.status == ConnectionStatus.inactive.rawValue {
                actions.remove(at: 2)

                let reconnect = UIAction(title: l10n(.reconnect), image: UIImage(systemName: "arrow.clockwise")) { _ in
                    strongSelf.delegate?.reconnectPreseed(id: strongSelf.connection.id)
                }
                actions.insert(reconnect, at: 0)

                let remove = UIAction(title: l10n(.remove), image: UIImage(systemName: "xmark")) { _ in
                    strongSelf.delegate?.deletePressed(id: strongSelf.connection.id, showConfirmation: false)
                }
                actions.insert(remove, at: 3)
            }

            return UIMenu(title: "", image: nil, identifier: nil, options: .destructive, children: actions)
        }
        return configuration
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
