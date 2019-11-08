//
//  ConnectionsCoordinator.swift
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
import SEAuthenticator

final class ConnectionsCoordinator: Coordinator {
    let rootViewController = ConnectionsViewController()

    private var editConnectionCoordinator: EditConnectionCoordinator?
    private var connectViewCoordinator: ConnectViewCoordinator?

    private let connections = ConnectionsCollector.allConnections.sorted(
        byKeyPath: #keyPath(Connection.createdAt),
        ascending: true
    )

    private let activeConnections = ConnectionsCollector.activeConnections

    func start() {
        rootViewController.delegate = self
    }

    func stop() {}

    private func reconnect(_ connection: Connection) {
        connectViewCoordinator = ConnectViewCoordinator(
            rootViewController: rootViewController,
            connectionType: .reconnect,
            connection: connection
        )
        connectViewCoordinator?.start()
    }

    private func remove(_ connection: Connection) {
        rootViewController.navigationController?.showConfirmationAlert(
            withTitle: l10n(.delete),
            message: l10n(.deleteConnectionDescription),
            confirmAction: { _ in
                let expiresAt = Date().addingTimeInterval(5.0 * 60.0).utcSeconds
                ConnectionsInteractor.revoke(connection, expiresAt: expiresAt)
                SECryptoHelper.deleteKeyPair(with: SETagHelper.create(for: connection.guid))
                ConnectionRepository.delete(connection)
            }
        )
    }

    private func rename(_ connection: Connection) {
        editConnectionCoordinator = EditConnectionCoordinator(
            rootViewController: rootViewController,
            connection: connection
        )
        editConnectionCoordinator?.start()
    }
}

// MARK: - Actions
private extension ConnectionsCoordinator {
    func showActionSheet(for connection: Connection) {
        guard let tabBarVC = AppDelegate.main.tabBarViewController else { return }

        let actionSheet = CustomActionSheetViewController()

        let reconnectAction: Action = { [weak self] in actionSheet.dismissActionSheetWithCompletion {
                guard let strongSelf = self else { return }

                strongSelf.reconnect(connection)
            }
        }

        let contactSupportAction: Action = { [weak self] in actionSheet.dismissActionSheetWithCompletion {
                self?.rootViewController.showSupportMailComposer(withEmail: connection.supportEmail)
            }
        }

        let renameAction: Action = { [weak self] in actionSheet.dismissActionSheetWithCompletion {
                guard let strongSelf = self else { return }

                strongSelf.rename(connection)
            }
        }

        let deleteAction: Action = { [weak self] in actionSheet.dismissActionSheetWithCompletion {
                guard let strongSelf = self else { return }

                strongSelf.remove(connection)
            }
        }

        var actionsArray: [(actionSheetItem: ActionSheetAction, action: Action)] = [
            (.rename, renameAction),
            (.support, contactSupportAction),
            (.delete, deleteAction)
        ]

        if connection.status == ConnectionStatus.inactive.rawValue {
            actionsArray.insert((.reconnect, reconnectAction), at: 0)
        }

        actionSheet.actions = ConnectionActionSheetBuilder.createActions(from: actionsArray)
        tabBarVC.present(actionSheet, animated: true)
    }
}

// MARK: - ConnectionsViewControllerDelegate
extension ConnectionsCoordinator: ConnectionsViewControllerDelegate {
    func selected(_ connection: Connection, action: ConnectionAction?) {
        guard let action = action else { showActionSheet(for: connection); return }
    
        switch action {
        case .delete: remove(connection)
        case .edit: rename(connection)
        case .reconnect: reconnect(connection)
        }
    }

    func addPressed() {
        connectViewCoordinator = ConnectViewCoordinator(
            rootViewController: rootViewController,
            connectionType: .connect
        )
        connectViewCoordinator?.start()
    }
}
