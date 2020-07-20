//
//  LanguagePickerViewController.swift
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

final class LanguagePickerViewController: BaseViewController {
    static let reuseIdentifier = "LanguagePickerCell"
    private let tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    private var viewModel: LanguagePickerViewModel

    init(viewModel: LanguagePickerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .authenticator_main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = l10n(.language)
        setupTableView()
        layout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension LanguagePickerViewController {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = 30.0
        tableView.sectionFooterHeight = 0.0
        tableView.backgroundColor = .backgroundColor
        tableView.separatorStyle = .none
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: LanguagePickerViewController.reuseIdentifier
        )
    }
}

// MARK: - UITableViewDataSource
extension LanguagePickerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: LanguagePickerViewController.reuseIdentifier,
            for: indexPath
        )
        cell.textLabel?.textAlignment = .left
        cell.textLabel?.textColor = .titleColor
        cell.textLabel?.font = .auth_17regular
        cell.textLabel?.text = viewModel.cellTitle(for: indexPath)
        cell.accessoryType = viewModel.cellAccessoryType(for: indexPath)
        cell.tintColor = .lightBlue
        cell.backgroundColor = .backgroundColor
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rows(for: section)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AppLayout.cellDefaultHeight
    }
}

// MARK: - UITableViewDelegate
extension LanguagePickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        QuickActionsHelper.setupActions()
        viewModel.selected(indexPath: indexPath)
    }
}

// MARK: - Layout
extension LanguagePickerViewController: Layoutable {
    func layout() {
        view.addSubview(tableView)
        tableView.edges(to: view)
    }
}
