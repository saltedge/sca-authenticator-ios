//
//  ConnectionViewModel.swift
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
    func accessLocationPressed()
    func supportPressed(email: String)
    func deletePressed(id: String, showConfirmation: Bool)
    func reconnectPreseed(id: String)
    func consentsPressed(id: String)
}

@dynamicMemberLookup
class ConnectionCellViewModel {
    private let connection: Connection
    private let consentsCount: Int

    weak var delegate: ConnectionCellEventsDelegate?

    var connectionStatus = Observable<ConnectionStatus>(.active)

    var connectionName: String {
        return connection.name
    }

    var description: NSAttributedString {
        if LocationManager.shared.shouldShowLocationWarning(connection: connection) {
            return NSAttributedString(
                string: l10n(.grantAccessToLocationServices),
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.descriptionYellow]
            )
        } else {
            return connectionStatus.value == .inactive
                ? buildInactiveDescription()
                : buildActiveDescription()
        }
    }

    var hasConsents: Bool {
        return consentsCount > 0
    }

    init(connection: Connection, consentsCount: Int = 0) {
        self.connection = connection
        self.consentsCount = consentsCount
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

            var actions: [UIAction] = []

            if self?.connection.status == ConnectionStatus.inactive.rawValue {
                actions.append(UIAction(title: l10n(.reconnect), image: UIImage(systemName: "arrow.clockwise")) { _ in
                    strongSelf.delegate?.reconnectPreseed(id: strongSelf.connection.id)
                })
            }

            actions.append(UIAction(title: l10n(.rename), image: UIImage(systemName: "square.and.pencil")) { _ in
                strongSelf.delegate?.renamePressed(id: strongSelf.connection.id)
            })

            actions.append(UIAction(title: l10n(.contactSupport), image: UIImage(systemName: "envelope")) { _ in
                strongSelf.delegate?.supportPressed(email: strongSelf.connection.supportEmail)
            })

            if self?.hasConsents == true {
                actions.append(
                    UIAction(title: l10n(.viewConsents), image: UIImage(systemName: "doc.plaintext")) { _ in
                        strongSelf.delegate?.consentsPressed(id: strongSelf.connection.id)
                    }
                )
            }
            if LocationManager.shared.shouldShowLocationWarning(connection: self?.connection) {
                actions.append(
                    UIAction(title: l10n(.accessToLocation), image: UIImage(systemName: "mappin.and.ellipse")) { _ in
                        strongSelf.delegate?.accessLocationPressed()
                    }
                )
            }

            if self?.connection.status == ConnectionStatus.inactive.rawValue {
                actions.append(
                    UIAction(title: l10n(.remove), image: UIImage(systemName: "xmark")) { _ in
                        strongSelf.delegate?.deletePressed(id: strongSelf.connection.id, showConfirmation: false)
                    }
                )
            } else {
                actions.append(
                    UIAction(title: l10n(.delete), image: UIImage(systemName: "trash")) { _ in
                        strongSelf.delegate?.deletePressed(id: strongSelf.connection.id, showConfirmation: true)
                    }
                )
            }
            
            actions.append(
                UIAction(
                    title: "\(l10n(.id)) \(strongSelf.connection.id)",
                    image: UIImage(systemName: "info.circle"),
                    attributes: .disabled) { _ in return }
            )

            return UIMenu(title: "", image: nil, identifier: nil, options: .destructive, children: actions)
        }
        return configuration
    }

    private func buildInactiveDescription() -> NSAttributedString {
        let baseStatusAttribute = [
            NSAttributedString.Key.foregroundColor: UIColor.redAlert,
            NSAttributedString.Key.font: UIFont.auth_13regular
        ]
        return NSAttributedString(string: l10n(.inactiveConnection), attributes: baseStatusAttribute)
    }

    private func buildActiveDescription() -> NSAttributedString {
        let baseStatusAttribute = [
            NSAttributedString.Key.foregroundColor: UIColor.dark60,
            NSAttributedString.Key.font: UIFont.auth_13regular
        ]
        let baseStatus = NSAttributedString(
            string: "\(l10n(.connectedOn)) \(connection.createdAt.dayMonthYearWithTimeString)",
            attributes: baseStatusAttribute
        )

        if consentsCount == 0 { return baseStatus }

        let consentsCountString = consentsCount > 1 ? l10n(.consents) : l10n(.consent)

        let extendedStatusAttribute = [
            NSAttributedString.Key.foregroundColor: UIColor.dark60,
            NSAttributedString.Key.font: UIFont.auth_13medium
        ]
        let extendedStatus = NSMutableAttributedString(
            string: "\(consentsCount) \(consentsCountString) • ",
            attributes: extendedStatusAttribute
        )
        extendedStatus.append(baseStatus)
        return extendedStatus
    }
}

private extension ConnectionCellViewModel {
    static func dayMonthYearWithTimeDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}

private extension Date {
    var dayMonthYearWithTimeString: String {
        return ConnectionCellViewModel.dayMonthYearWithTimeDateFormatter().string(from: self)
    }
}
