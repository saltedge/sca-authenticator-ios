//
//  LanguageViewController.swift
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

protocol LanguagePickerDelegate: class {
    func languagePicker(selected language: String)
}

final class LanguageViewController: BaseViewController {
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: LanguagePickerDataSource.reuseIdentifier)
        tableView.sectionHeaderHeight = 30.0
        tableView.sectionFooterHeight = 0.0
        return tableView
    }()
    private var dataSource: LanguagePickerDataSource
    private var selectedLanguage = UserDefaultsHelper.applicationLanguage
    weak var delegate: LanguagePickerDelegate?

    init(dataSource: LanguagePickerDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: .authenticator_main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = l10n(.language)
        setupTableView()
        layout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewDataSource
extension LanguageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LanguagePickerDataSource.reuseIdentifier, for: indexPath)
        cell.textLabel?.text = dataSource.language(for: indexPath)
        cell.textLabel?.textAlignment = .left
        let convertedLanguage = LocalizationHelper.languageDisplayName(from: selectedLanguage)
        cell.accessoryType = convertedLanguage == dataSource.language(for: indexPath) ? .checkmark : .none
        cell.tintColor = .auth_blue
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.items.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AppLayout.cellDefaultHeight
    }
}

// MARK: - UITableViewDelegate
extension LanguageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.languagePicker(selected: selectedLanguage)
    }
}

// MARK: - Setup
private extension LanguageViewController {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - Layout
extension LanguageViewController: Layoutable {
    func layout() {
        view.addSubview(tableView)
        tableView.edges(to: view)
    }
}
