//
//  ConnectionsListViewModel.swift
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

protocol ConnectionsListEventsDelegate: class {
    func showEditConnectionAlert(placeholder: String, completion: @escaping (String) -> ())
    func showSupport(email: String)
    func deleteConnection(completion: @escaping () -> ())
    func reconnect(by id: String)
    func updateViews()
    func addPressed()
}

final class ConnectionsListViewModel {
    weak var delegate: ConnectionsListEventsDelegate?

    private let connections = ConnectionsCollector.allConnections.sorted(
        byKeyPath: #keyPath(Connection.createdAt),
        ascending: true
    )

    private var connectionsNotificationToken: NotificationToken?

    private var connectionsListener: RealmConnectionsListener?

    init() {
        connectionsListener = RealmConnectionsListener(
            onDataChange: {
                self.delegate?.updateViews()
            },
            type: .all
        )
    }

    var count: Int {
        return connections.count
    }

    var hasDataToShow: Bool {
        return count > 0
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

        ConnectionsInteractor.revoke(connection)
        SECryptoHelper.deleteKeyPair(with: SETagHelper.create(for: connection.guid))
        ConnectionRepository.delete(connection)
    }

    func updateName(by id: String) {
        guard let connection = ConnectionsCollector.with(id: id) else { return }

        delegate?.showEditConnectionAlert(
            placeholder: connection.name,
            completion: { newName in
                guard !ConnectionsCollector.connectionNames.contains(newName) else { return }

                ConnectionRepository.updateName(connection, name: newName)
            }
        )
    }

    func addPressed() {
        delegate?.addPressed()
    }

    private func item(for indexPath: IndexPath) -> Connection? {
        if indexPath.row == 0 && connections.indices.contains(indexPath.section) {
            return connections[indexPath.section]
        }
        return nil
    }

    deinit {
        connectionsNotificationToken?.invalidate()
    }
}

// MARK: - Actions
extension ConnectionsListViewModel {
    func actionSheet(for indexPath: IndexPath) -> UIAlertController {
        let viewModel = cellViewModel(at: indexPath)
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let cancel = UIAlertAction(title: l10n(.cancel), style: .cancel)

        let delete = UIAlertAction(title: l10n(.delete), style: .default) { _ in
            self.delegate?.deleteConnection(
                completion: {
                    self.remove(at: indexPath)
                }
            )
        }

        let rename = UIAlertAction(title: l10n(.rename), style: .default) { _ in
            self.updateName(by: viewModel.id)
        }

        var actions: [UIAlertAction] = [delete, rename, cancel]

        if viewModel.status == ConnectionStatus.inactive.rawValue {
            let reconnect = UIAlertAction(title: l10n(.reconnect), style: .default) { _ in
                self.delegate?.reconnect(by: viewModel.id)
            }
            actions.insert(reconnect, at: 0)
        }

        actions.forEach { actionSheet.addAction($0) }
        return actionSheet
    }

    func rightSwipeActionsConfiguration(for indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let viewModel = cellViewModel(at: indexPath)

        let delete = UIContextualAction(style: .destructive, title: "") { _, _, completionHandler in
            self.delegate?.deleteConnection(
                completion: {
                    self.remove(at: indexPath)
                }
            )
            completionHandler(true)
        }
        delete.image = UIImage(named: "delete")

        let rename = UIContextualAction(style: .normal, title: "") { _, _, completionHandler in
            self.updateName(by: viewModel.id)
            completionHandler(true)
        }
        rename.image = UIImage(named: "rename")

        var actions: [UIContextualAction] = [delete, rename]

        if viewModel.status == ConnectionStatus.inactive.rawValue {
            let reconnect = UIContextualAction(style: .normal, title: "") { _, _, completionHandler in
                self.delegate?.reconnect(by: viewModel.id)
                completionHandler(true)
            }
            reconnect.image = UIImage(named: "reconnect")
            actions.insert(reconnect, at: 1)
        }
        actions.forEach { $0.backgroundColor = .backgroundColor }

        return UISwipeActionsConfiguration(actions: actions)
    }

    func leftSwipeActionsConfiguration(for indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let viewModel = cellViewModel(at: indexPath)

        let support = UIContextualAction(style: .normal, title: "") { _, _, completionHandler in
            self.delegate?.showSupport(email: viewModel.supportEmail)
            completionHandler(true)
        }
        support.image = UIImage(named: "contact_support")
        support.backgroundColor = .backgroundColor

        return UISwipeActionsConfiguration(actions: [support])
    }

    @available(iOS 13.0, *)
    func contextMenuConfiguration(for indexPath: IndexPath) -> UIContextMenuConfiguration {
        let viewModel = cellViewModel(at: indexPath)

        let configuration = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { [weak self] _ -> UIMenu? in
            let rename = UIAction(title: l10n(.rename), image: UIImage(named: "rename")) { _ in
                self?.updateName(by: viewModel.id)
            }
            let support = UIAction(title: l10n(.support), image: UIImage(named: "contact_support")) { _ in
                self?.delegate?.showSupport(email: viewModel.supportEmail)
            }
            let delete = UIAction(title: l10n(.delete), image: UIImage(named: "delete")) { _ in
                self?.delegate?.deleteConnection(
                    completion: {
                        self?.remove(at: indexPath)
                    }
                )
            }

            var actions: [UIAction] = [rename, support, delete]

            if viewModel.status == ConnectionStatus.inactive.rawValue {
                let reconnect = UIAction(title: l10n(.reconnect), image: UIImage(named: "reconnect")) { _ in
                    self?.delegate?.reconnect(by: viewModel.id)
                }
                actions.insert(reconnect, at: 0)
            }

            return UIMenu(title: "", image: nil, identifier: nil, options: .destructive, children: actions)
        }
        return configuration
    }
}
