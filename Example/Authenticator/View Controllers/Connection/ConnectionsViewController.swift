//
//  ConnectionsViewController.swift
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
import TinyConstraints

final class ConnectionsViewController: BaseViewController {
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.sectionHeaderHeight = 0.0
        tableView.sectionFooterHeight = 0.0
        tableView.backgroundColor = .backgroundColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.register(ConnectionCell.self)
        tableView.separatorStyle = .none
        return tableView
    }()
    private var noDataView: NoDataView!

    private var viewControllerViewModel: ConnectionsListViewModel!
    private var dataSource: ConnectionsDataSource!

    weak var delegate: ConnectionsViewControllerDelegate?
    var connectViewCoordinator: ConnectViewCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViewModelAndDataSource()
        setupTableView()
        setupNoDataView()
        layout()
        updateViewsHiddenState()
        NotificationsHelper.observe(
            self,
            selector: #selector(reloadData),
            name: NSLocale.currentLocaleDidChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationsHelper.removeObserver(self)
    }

    @objc private func addPressed() {
        addNewConnection()
    }

    @objc private func reloadData() {
        tableView.reloadData()
    }
}

enum ConnectionMenuAction {
    case delete
    case edit
    case reconnect
    case support
}

protocol ConnectionsViewControllerDelegate: class {
    func selected(_ connection: Connection, action: ConnectionMenuAction?)
    func addPressed()
}

struct ConnectionsListLayout {
    static let cellHeight: CGFloat = 96.0
}

// MARK: - Setup
private extension ConnectionsViewController {
    func setupNavigationBar() {
        navigationItem.title = l10n(.connections)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: l10n(.back),
            style: .plain,
            target: self,
            action: #selector(close)
        )
    }

    func setupViewModelAndDataSource() {
        viewControllerViewModel = ConnectionsListViewModel(
            onDataChange: { [weak self] in
                guard let weakSelf = self else { return }

                weakSelf.tableView.reloadData()
                weakSelf.updateViewsHiddenState()
            }
        )

        dataSource = ConnectionsDataSource(viewModel: viewControllerViewModel)
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    func setupNoDataView() {
        noDataView = NoDataView(
            image: #imageLiteral(resourceName: "no_connections"),
            title: l10n(.noConnections),
            description: l10n(.noConnectionsDescription),
            ctaTitle: l10n(.connectProvider)
        )
    }

    func updateViewsHiddenState() {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.noDataView.alpha = self.dataSource.hasDataToShow ? 0.0 : 1.0
                self.tableView.alpha = !self.dataSource.hasDataToShow ? 0.0 : 1.0
            }
        )
    }
}

// MARK: UITableViewDataSource
extension ConnectionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ConnectionsListLayout.cellHeight
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.rows(for: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return dataSource.cell(for: indexPath)
    }
}

// MARK: UITableViewDelegate
extension ConnectionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showActionSheet(at: indexPath)
    }
}

// MARK: UISwipeActionsConfiguration
@available(iOS 11.0, *)
extension ConnectionsViewController {
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: l10n(.delete)) { _, _, completionHandler in
            self.navigationController?.showConfirmationAlert(
                withTitle: l10n(.delete),
                message: l10n(.deleteConnectionDescription),
                confirmAction: { _ in
                    self.viewControllerViewModel.remove(at: indexPath)
                }
            )
            completionHandler(true)
        }

        let rename = UIContextualAction(style: .normal, title: l10n(.rename)) { _, _, completionHandler in
            guard let connectionId = self.viewControllerViewModel.connectionId(at: indexPath) else { return }

            self.rename(connectionId)
            completionHandler(true)
        }

        var actions: [UIContextualAction] = [delete, rename]

        if viewControllerViewModel.cellViewModel(at: indexPath).status == ConnectionStatus.inactive.rawValue {
            let reconnect = UIContextualAction(style: .normal, title: l10n(.reconnect)) { _, _, completionHandler in
                guard let connectionId = self.viewControllerViewModel.connectionId(at: indexPath) else { return }

                self.reconnect(connectionId)
                completionHandler(true)
            }
            reconnect.backgroundColor = UIColor.auth_blue
            actions.insert(reconnect, at: 1)
        }

        return UISwipeActionsConfiguration(actions: actions)
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let connectionViewModel = viewControllerViewModel.cellViewModel(at: indexPath)

        let support = UIContextualAction(style: .normal, title: l10n(.support)) { _, _, completionHandler in
            self.showSupport(email: connectionViewModel.supportEmail)
            completionHandler(true)
        }

        return UISwipeActionsConfiguration(actions: [support])
    }
}

// MARK: - Actions
private extension ConnectionsViewController {
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }

    func showActionSheet(at indexPath: IndexPath) {}

    func rename(_ id: String) {
        let editVc = EditConnectionViewController(connectionId: id)
        editVc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(editVc, animated: true)
    }

    func showSupport(email: String) {
        showSupportMailComposer(withEmail: email)
    }

    func reconnect(_ connectionId: String) {
        connectViewCoordinator = ConnectViewCoordinator(
            rootViewController: self,
            connectionType: .reconnect,
            connectionId: connectionId
        )
        connectViewCoordinator?.start()
    }

    func addNewConnection() {
        AVCaptureHelper.requestAccess(
            success: {
                self.connectViewCoordinator = ConnectViewCoordinator(
                    rootViewController: self,
                    connectionType: .connect
                )
                self.connectViewCoordinator?.start()
            },
            failure: {
                self.showConfirmationAlert(
                    withTitle: l10n(.deniedCamera),
                    message: l10n(.deniedCameraDescription),
                    confirmActionTitle: l10n(.goToSettings),
                    confirmActionStyle: .default,
                    confirmAction: { _ in
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }
                )
            }
        )
    }
}

// MARK: - Layout
extension ConnectionsViewController: Layoutable {
    func layout() {
        view.backgroundColor = .backgroundColor
        view.addSubviews(tableView, noDataView)
        tableView.edges(to: view)
        noDataView.left(to: view, offset: AppLayout.sideOffset)
        noDataView.right(to: view, offset: -AppLayout.sideOffset)
        noDataView.center(in: view)
    }
}
