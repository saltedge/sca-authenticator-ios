//
//  EditConnectionCoordinator.swift
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

final class EditConnectionCoordinator: Coordinator {
    private var rootViewController: UIViewController
    private var editConnectionViewController: EditConnectionViewController
    private var connection: Connection

    init(rootViewController: UIViewController, connection: Connection) {
        self.connection = connection
        self.rootViewController = rootViewController
        self.editConnectionViewController = EditConnectionViewController(connection: connection)
    }

    func start() {
        editConnectionViewController.delegate = self
        rootViewController.navigationController?.pushViewController(
            editConnectionViewController, animated: true
        )
    }

    func stop() {}
}

// MARK: - EditConnectionViewControllerDelegate
extension EditConnectionCoordinator: EditConnectionViewControllerDelegate {
    func donePressed(text: String?) {
        guard let name = text, !ConnectionsCollector.connectionNames.contains(name) else {
            editConnectionViewController.showConfirmationAlert(withTitle: "This name already exists.")
            return
        }

        try? RealmManager.performRealmWriteTransaction {
            connection.name = name
        }
        editConnectionViewController.navigationController?.popViewController(animated: true)
    }
}
