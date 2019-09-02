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

protocol ConnectionsViewControllerDelegate: class {
    func selected(_ connection: Connection)
    func addPressed()
    func deleteAllPressed()
}

private struct Layout {
    static let cellHeight: CGFloat = 86.0
}

final class ConnectionsViewController: BaseViewController {
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.sectionHeaderHeight = 30.0
        tableView.sectionFooterHeight = 0.0
        tableView.backgroundColor = .auth_backgroundColor
        tableView.register(ConnectionCell.self)
        return tableView
    }()
    private var noDataView: NoDataView!
    private var dataSource: ConnectionsDataSource!

    weak var delegate: ConnectionsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = l10n(.connections)
        view.backgroundColor = .auth_backgroundColor
        setupDataSource()
        setupTableView()
        noDataView = NoDataView(
            image: #imageLiteral(resourceName: "no_connections"),
            title: l10n(.noConnections),
            description: l10n(.noConnectionsDescription),
            ctaTitle: l10n(.connect),
            onCTAPress: {
                self.addPressed()
            }
        )
        layout()
        updateViewsHiddenState()
        updateNavigationButtonsState()
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
        delegate?.addPressed()
    }

    @objc private func deleteAllPressed() {
        delegate?.deleteAllPressed()
    }

    @objc private func reloadData() {
        tableView.reloadData()
    }
}

// MARK: - Setup
private extension ConnectionsViewController {
    func setupDataSource() {
        dataSource = ConnectionsDataSource(
            onDataChange: { [weak self] in
                guard let weakSelf = self else { return }

                weakSelf.tableView.reloadData()
                weakSelf.updateViewsHiddenState()
                weakSelf.updateNavigationButtonsState()
            }
        )
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
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

    func updateNavigationButtonsState() {
        if dataSource.hasDataToShow {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: l10n(.deleteAll),
                style: .plain,
                target: self,
                action: #selector(deleteAllPressed)
            )
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: #imageLiteral(resourceName: "Add"),
                style: .plain,
                target: self,
                action: #selector(addPressed)
            )
        } else {
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
        }
    }
}

// MARK: UITableViewDataSource
extension ConnectionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Layout.cellHeight
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

        guard let connection = dataSource.item(for: indexPath) else { return }

        delegate?.selected(connection)
    }
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
