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

private struct Layout {
    static let footerHeight: CGFloat = 60.0
}

final class AboutViewController: BaseViewController {
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let footerViewLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .backgroundColor
        label.text = l10n(.copyrightDescription)
        label.font = .systemFont(ofSize: 15.0)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .titleColor
        label.textAlignment = .center
        return label
    }()
    private var viewModel: AboutViewModel

    init(viewModel: AboutViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .authenticator_main)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}

// MARK: - Setup
private extension AboutViewController {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = 30.0
        tableView.sectionFooterHeight = 0.0
        tableView.backgroundColor = .backgroundColor
        tableView.separatorStyle = .none
        tableView.register(SettingsCell.self)
    }
}

// MARK: UITableViewDataSource
extension AboutViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AppLayout.cellDefaultHeight
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rows(for: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = viewModel.item(for: indexPath) else { return UITableViewCell() }

        let cell: SettingsCell = tableView.dequeueReusableCell(for: indexPath)
        cell.set(with: item)
        return cell
    }
}

// MARK: UITableViewDelegate
extension AboutViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selected(indexPath: indexPath)
    }
}

// MARK: - Layout
extension AboutViewController: Layoutable {
    func layout() {
        view.addSubviews(tableView, footerViewLabel)

        tableView.edges(to: view)

        footerViewLabel.height(AppLayout.cellDefaultHeight)
        footerViewLabel.widthToSuperview()
        footerViewLabel.bottom(to: view, view.safeAreaLayoutGuide.bottomAnchor, offset: -16.0)
    }
}
