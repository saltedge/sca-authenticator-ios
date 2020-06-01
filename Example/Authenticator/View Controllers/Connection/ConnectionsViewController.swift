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

enum ConnectionMenuAction {
    case delete
    case edit
    case reconnect
    case support
}

private struct Layout {
    static let cellHeight: CGFloat = 96.0
}

final class ConnectionsViewController: BaseViewController {
    private let tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    private var noDataView: NoDataView!

    private var viewControllerViewModel: ConnectionsListViewModel

    var connectViewCoordinator: ConnectViewCoordinator?

    init(viewModel: ConnectionsListViewModel) {
        viewControllerViewModel = viewModel
        super.init(nibName: nil, bundle: .authenticator_main)
        setupNoDataView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        layout()
        updateViewsHiddenState()
        NotificationsHelper.observe(
            self,
            selector: #selector(reloadData),
            name: NSLocale.currentLocaleDidChangeNotification,
            object: nil
        )
    }

    @objc private func reloadData() {
        tableView.reloadData()
    }

    func updateViewsHiddenState() {
        tableView.reloadData()
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.noDataView.alpha = self.viewControllerViewModel.hasDataToShow ? 0.0 : 1.0
                self.tableView.alpha = !self.viewControllerViewModel.hasDataToShow ? 0.0 : 1.0
            }
        )
    }

    deinit {
        NotificationsHelper.removeObserver(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = 0.0
        tableView.sectionFooterHeight = 0.0
        tableView.backgroundColor = .backgroundColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.register(ConnectionCell.self)
        tableView.separatorStyle = .none
    }

    func setupNoDataView() {
        noDataView = NoDataView(
            image: #imageLiteral(resourceName: "no_connections"),
            title: l10n(.noConnections),
            description: l10n(.noConnectionsDescription),
            ctaTitle: l10n(.connectProvider),
            action: viewControllerViewModel.addPressed
        )
        noDataView.alpha = viewControllerViewModel.hasDataToShow ? 0 : 1
    }
}

// MARK: UITableViewDataSource
extension ConnectionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Layout.cellHeight
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewControllerViewModel.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ConnectionCell = tableView.dequeueReusableCell(for: indexPath)
        cell.viewModel = viewControllerViewModel.cellViewModel(at: indexPath)

        return cell
    }
}

// MARK: UITableViewDelegate
extension ConnectionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showActionSheet(at: indexPath)
    }
}

@available(iOS 13.0, *)
extension ConnectionsViewController {
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        return viewControllerViewModel.contextMenuConfiguration(for: indexPath)
    }
}

// MARK: UISwipeActionsConfiguration
extension ConnectionsViewController {
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return viewControllerViewModel.rightSwipeActionsConfiguration(for: indexPath)
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return viewControllerViewModel.leftSwipeActionsConfiguration(for: indexPath)
    }
}

// MARK: - Actions
private extension ConnectionsViewController {
    func showActionSheet(at indexPath: IndexPath) {}
}

// MARK: - Layout
extension ConnectionsViewController: Layoutable {
    func layout() {
        view.addSubviews(tableView, noDataView)

        tableView.edges(to: view)

        noDataView.left(to: view, offset: AppLayout.sideOffset)
        noDataView.right(to: view, offset: -AppLayout.sideOffset)
        noDataView.center(in: view)
    }
}
