//
//  SettingsViewController.swift
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

protocol SettingsViewControllerDelegate: class {
    func selected(_ item: SettingsCellType, indexPath: IndexPath)
}

final class SettingsViewController: BaseViewController {
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let dataSource = SettingsDataSource()

    weak var delegate: SettingsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = l10n(.settings)
        setupTableView()
        layout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    func reloadData() {
        tableView.reloadData()
    }
}

// MARK: - Setup
private extension SettingsViewController {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = 30.0
        tableView.sectionFooterHeight = 0.0
        tableView.backgroundColor = .auth_backgroundColor
        tableView.register(SettingsCell.self)
    }
}

// MARK: UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AppLayout.cellDefaultHeight
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.rows(for: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SettingsCell = tableView.dequeueReusableCell(for: indexPath)

        guard let item = dataSource.item(for: indexPath) else { return UITableViewCell() }

        cell.set(with: item)
        return cell
    }
}

// MARK: UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let item = dataSource.item(for: indexPath) else { return }

        delegate?.selected(item, indexPath: indexPath)
    }
}

// MARK: - Layout
extension SettingsViewController: Layoutable {
    func layout() {
        view.addSubview(tableView)
        tableView.edges(to: view)
    }
}
