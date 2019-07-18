//
//  AboutViewController.swift
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

protocol AboutViewControllerDelegate: class {
    func selected(_ item: SettingsCellType, indexPath: IndexPath)
}

private struct Layout {
    static let footerHeight: CGFloat = 60.0
}

final class AboutViewController: BaseViewController {
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var dataSource: AboutDataSource

    weak var delegate: AboutViewControllerDelegate?

    init(dataSource: AboutDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: .authenticator_main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = l10n(.about)
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension AboutViewController {
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
extension AboutViewController: UITableViewDataSource {
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

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UILabel(
            frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: AppLayout.cellDefaultHeight)
        )
        footerView.backgroundColor = .auth_backgroundColor
        footerView.text = l10n(.copyrightDescription)
        footerView.font = .auth_15regular
        footerView.numberOfLines = 0
        footerView.lineBreakMode = .byWordWrapping
        footerView.textColor = .auth_darkGray
        footerView.textAlignment = .center
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return Layout.footerHeight
    }
}

// MARK: UITableViewDelegate
extension AboutViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let item = dataSource.item(for: indexPath) else { return }

        delegate?.selected(item, indexPath: indexPath)
    }
}

// MARK: - Layout
extension AboutViewController: Layoutable {
    func layout() {
        view.addSubview(tableView)

        tableView.edges(to: view)
    }
}
