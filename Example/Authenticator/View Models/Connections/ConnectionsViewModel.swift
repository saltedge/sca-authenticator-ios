//
//  ConnectionsViewModel.swift
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
import SEAuthenticatorCore

protocol ConnectionsEventsDelegate: class {
    func showEditConnectionAlert(placeholder: String, completion: @escaping (String) -> ())
    func showSupport(email: String)
    func deleteConnection(completion: @escaping () -> ())
    func reconnect(by id: String)
    func consentsPressed(connectionId: String, consents: [SEConsentData])
    func updateViews()
    func addPressed()
    func presentError(_ error: String)
    func showNoInternetConnectionAlert(completion:@escaping () -> Void)
    func showDeleteConfirmationAlert(completion:@escaping () -> Void)
}

final class ConnectionsViewModel {
    weak var delegate: ConnectionsEventsDelegate?

    private let connections = ConnectionsCollector.allConnections
    private var consentsDict: [String: [SEConsentData]] = [:]

    private var connectionsNotificationToken: NotificationToken?
    private var connectionsListener: RealmConnectionsListener?

    private let reachabilityManager: ReachabilityManagerProtocol

    init(reachabilityManager: ReachabilityManagerProtocol) {
        self.reachabilityManager = reachabilityManager
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

    var emptyViewData: EmptyViewData {
        return EmptyViewData(
            image: UIImage(named: "noConnections", in: .authenticator_main, compatibleWith: nil)!,
            title: l10n(.noConnections),
            description: l10n(.noConnectionsDescription),
            buttonTitle: l10n(.connect)
        )
    }

    func cellViewModel(at indexPath: IndexPath) -> ConnectionCellViewModel {
        let connection = item(for: indexPath)!

        return ConnectionCellViewModel(
            connection: connection,
            consentsCount: consentsDict[connection.id]?.count ?? 0
        )
    }

    func connectionId(at indexPath: IndexPath) -> String? {
        guard let connection = item(for: indexPath) else { return nil }

        return connection.id
    }

    func updateDataSource(with consents: [SEConsentData]) {
        consentsDict = Dictionary(grouping: consents, by: { $0.connectionId })
        delegate?.updateViews()
    }

    private func revoke(connection: Connection, interactor: BaseConnectionsInteractor) {
        interactor.revoke(
            connection,
            success: { },
            failure: { error in
                self.delegate?.presentError(error)
            }
        )
        deleteConnection(connection: connection)
    }

    private func deleteConnection(connection: Connection) {
        SECryptoHelper.deleteKeyPair(with: connection.providerPublicKeyTag)
        SECryptoHelper.deleteKeyPair(with: SETagHelper.create(for: connection.guid))
        ConnectionRepository.delete(connection)
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

// MARK: - Delegate actions
extension ConnectionsViewModel {
    func remove(at indexPath: IndexPath) {
        guard let connection = item(for: indexPath) else { return }

        revoke(
            connection: connection,
            interactor: connection.isApiV2 ? ConnectionsInteractorV2() : ConnectionsInteractor()
        )
    }

    func remove(by id: ID) {
        guard let connection = ConnectionsCollector.with(id: id) else { return }

        revoke(
            connection: connection,
            interactor: connection.isApiV2 ? ConnectionsInteractorV2() : ConnectionsInteractor()
        )
    }

    func updateName(by id: ID) {
        guard let connection = ConnectionsCollector.with(id: id) else { return }

        delegate?.showEditConnectionAlert(
            placeholder: connection.name,
            completion: { newName in
                guard !ConnectionsCollector.connectionNames.contains(newName) else { return }

                ConnectionRepository.updateName(connection, name: newName)
            }
        )
    }

    func showSupport(email: String) {
        delegate?.showSupport(email: email)
    }

    func consentsPressed(connectionId: String) {
        guard let consents = consentsDict[connectionId] else { return }

        delegate?.consentsPressed(connectionId: connectionId, consents: consents)
    }

    func addPressed() {
        delegate?.addPressed()
    }

    func reconnect(id: ID) {
        delegate?.reconnect(by: id)
    }

    func checkInternetAndRemoveConnection(id: String, showConfirmation: Bool) {
        guard reachabilityManager.isReachable else {
            delegate?.showNoInternetConnectionAlert {
                if self.reachabilityManager.isReachable { self.remove(by: id) }
            }
            return
        }
        if showConfirmation { delegate?.showDeleteConfirmationAlert { self.remove(by: id) }
        } else { remove(by: id) }
    }
}

// MARK: - Actions
extension ConnectionsViewModel {
    func actionSheet(for indexPath: IndexPath) -> UIAlertController {
        let viewModel = cellViewModel(at: indexPath)
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if viewModel.status == ConnectionStatus.inactive.rawValue {
            let reconnect = UIAlertAction(title: l10n(.reconnect), style: .default) { _ in
                self.delegate?.reconnect(by: viewModel.id)
            }
            actionSheet.addAction(reconnect)
        }

        if viewModel.hasConsents {
            actionSheet.addAction(
                UIAlertAction(title: l10n(.viewConsents), style: .default) { _ in
                    guard let connectionId = self.connectionId(at: indexPath),
                        let consents = self.consentsDict[connectionId] else { return }

                    self.delegate?.consentsPressed(connectionId: connectionId, consents: consents)
                }
            )
        }

        actionSheet.addAction(UIAlertAction(title: l10n(.rename), style: .default) { _ in
            self.updateName(by: viewModel.id)
        })

        let deleteTitle = viewModel.status == ConnectionStatus.inactive.rawValue ? l10n(.remove) : l10n(.delete)

        actionSheet.addAction(UIAlertAction(title: deleteTitle, style: .destructive) { _ in
            self.delegate?.deleteConnection(
                completion: {
                    self.remove(at: indexPath)
                }
            )
        })

        actionSheet.addAction(UIAlertAction(title: l10n(.cancel), style: .cancel))

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

        if viewModel.hasConsents {
            let viewConsents = UIContextualAction(style: .normal, title: "") { _, _, completionHandler in
                guard let connectionId = self.connectionId(at: indexPath),
                    let consents = self.consentsDict[connectionId] else { return }

                self.delegate?.consentsPressed(connectionId: connectionId, consents: consents)
                completionHandler(true)
            }
            viewConsents.image = UIImage(named: "consents")
            actions.append(viewConsents)
        }

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

    func refreshConsents(completion: (() -> ())? = nil) {
        CollectionsInteractor.consents.refresh(
            connections: Array(connections),
            success: { [weak self] encryptedConsents in
                guard let strongSelf = self else { return }

                DispatchQueue.global(qos: .background).async {
                    let decryptedConsents = encryptedConsents.compactMap { $0.decryptedConsentData }

                    DispatchQueue.main.async {
                        strongSelf.updateDataSource(with: decryptedConsents)
                        completion?()
                    }
                }
            },
            failure: { _ in
                completion?()
            },
            connectionNotFoundFailure: { connectionId in
                if let id = connectionId, let connection = ConnectionsCollector.with(id: id) {
                    ConnectionRepository.setInactive(connection)
                    completion?()
                }
            }
        )
    }
}
