//
//  ConsentsViewController
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

private struct Layout {
    static let cellHeight: CGFloat = 96.0
    static let logoViewTopOffset: CGFloat = 6.0
    static let logoViewLeftOffset: CGFloat = 16.0
    static let logoViewHeight: CGFloat = 36.0
    static let tableViewTopOffset: CGFloat = 12.0
}

final class ConsentsViewController: BaseViewController {
    private var consentsLogoView = ConsentLogoView()
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()

    var viewModel: ConsentsViewModel! {
        didSet {
            viewModel.delegate = self
            consentsLogoView.set(data: viewModel.logoViewData)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = l10n(.activeConsents)
        extendedLayoutIncludesOpaqueBars = true
        setupTableView()
        setupRefreshControl()
        layout()
    }

    @objc private func refresh() {
        viewModel.refreshConsents(
            completion: {
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                }
            }
        )
    }
}

// MARK: - Setup
private extension ConsentsViewController {
    private func setupTableView() {
        tableView.register(ConsentCell.self)
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = 0.0
        tableView.backgroundColor = .backgroundColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: l10n(.pullToRefresh))
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
}

// MARK: - UITableViewDataSource
extension ConsentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Layout.cellHeight
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.consentsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ConsentCell = tableView.dequeueReusableCell(for: indexPath)
        cell.viewModel = viewModel.cellViewModel(for: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ConsentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Layout
extension ConsentsViewController: Layoutable {
    func layout() {
        view.addSubviews(consentsLogoView, tableView)

        consentsLogoView.topToSuperview(offset: Layout.logoViewTopOffset)
        consentsLogoView.leftToSuperview(offset: Layout.logoViewLeftOffset)
        consentsLogoView.height(Layout.logoViewHeight)

        tableView.topToBottom(of: consentsLogoView, offset: Layout.tableViewTopOffset)
        tableView.widthToSuperview()
        tableView.bottomToSuperview()
    }
}

// MARK: - ConsentsEventsDelegate
extension ConsentsViewController: ConsentsEventsDelegate {
    func reloadData() {
        tableView.reloadData()
    }
}
