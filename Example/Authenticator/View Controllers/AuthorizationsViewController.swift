//
//  AuthorizationsViewController.swift
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

protocol AuthorizationsViewControllerDelegate: class {
    func selectedViewModel(at index: Int)
    func denyPressed(at index: Int)
    func confirmPressed(at index: Int, cell: AuthorizationCell)
    func modalClosed()
}

final class AuthorizationsViewController: BaseViewController {
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let noDataView = NoDataView(
        image: #imageLiteral(resourceName: "no_authorizations"),
        title: l10n(.noAuthorizations),
        description: l10n(.noAuthorizationsDescription)
    )
    private var messageBarView: MessageBarView?

    var dataSource: AuthorizationsDataSource?

    weak var delegate: AuthorizationsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = l10n(.authorizations)
        view.backgroundColor = .auth_backgroundColor
        setupTableView()
        setupObservers()
        layout()
        noDataView.alpha = 1.0
    }

    func reloadData() {
        tableView.reloadData()
    }

    @objc private func hasNoConnection() {
        messageBarView = present(message: l10n(.noInternetConnection), style: .warning, height: 60.0, hide: false)
    }

    @objc private func hasConnection() {
        if let messageBarView = messageBarView {
            dismiss(messageBarView: messageBarView)
        }
    }

    deinit {
        NotificationsHelper.removeObserver(self)
    }
}

// MARK: - Setup
extension AuthorizationsViewController {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .auth_backgroundColor
        tableView.register(AuthorizationCell.self)
        tableView.sectionHeaderHeight = 30.0
        tableView.sectionFooterHeight = 0.0
    }

    func setupObservers() {
        NotificationsHelper.observe(
            self,
            selector: #selector(hasConnection),
            name: .networkConnectionIsReachable,
            object: nil
        )

        NotificationsHelper.observe(
            self,
            selector: #selector(hasNoConnection),
            name: .networkConnectionIsNotReachable,
            object: nil
        )
    }

    func updateViewsHiddenState() {
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                guard let dataSource = self?.dataSource else { return }

                self?.noDataView.alpha = dataSource.hasDataToShow ? 0.0 : 1.0
                self?.tableView.alpha = !dataSource.hasDataToShow ? 0.0 : 1.0
            }
        )
    }
}

// MARK: - Actions
extension AuthorizationsViewController {
    func delete(section: Int) {
        tableView.beginUpdates()
        tableView.deleteSections([section], with: .fade)
        tableView.endUpdates()
        updateViewsHiddenState()
    }
}

// MARK: UITableViewDataSource
extension AuthorizationsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let dataSource = self.dataSource else { return 0 }

        return dataSource.sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataSource = self.dataSource else { return 0 }

        return dataSource.rows(for: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = dataSource?.cell(tableView: tableView, for: indexPath) else { return UITableViewCell() }

        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.height * 0.7
    }
}

// MARK: UITableViewDelegate
extension AuthorizationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let cell = tableView.cellForRow(at: indexPath) as? AuthorizationCell, cell.shouldShowPopup else { return }

        delegate?.selectedViewModel(at: indexPath.section)
    }
}

// MARK: - Layout
extension AuthorizationsViewController: Layoutable {
    func layout() {
        view.addSubviews(tableView, noDataView)
        tableView.edges(to: view)
        noDataView.left(to: view, offset: AppLayout.sideOffset)
        noDataView.right(to: view, offset: -AppLayout.sideOffset)
        noDataView.center(in: view)
    }
}

// MARK: - AuthorizationCellDelegate
extension AuthorizationsViewController: AuthorizationCellDelegate {
    func leftButtonPressed(_ cell: AuthorizationCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        cell.setProcessing(with: l10n(.processing))

        delegate?.denyPressed(at: indexPath.section)
    }

    func rightButtonPressed(_ cell: AuthorizationCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        delegate?.confirmPressed(at: indexPath.section, cell: cell)
    }

    func timerExpired(_ cell: AuthorizationCell) {
        guard let index = dataSource?.remove(cell.viewModel) else { return }

        delete(section: index)
    }

    func viewMorePressed(_ cell: AuthorizationCell) {
        guard let indexPath = tableView.indexPath(for: cell), cell.shouldShowPopup else { return }

        delegate?.selectedViewModel(at: indexPath.section)
    }
}

// MARK: - AuthorizationModalViewControllerDelegate
extension AuthorizationsViewController: AuthorizationModalViewControllerDelegate {
    func denyPressed() {}

    func confirmPressed() {}

    func buttonPressed(_ viewModel: AuthorizationViewModel) {
        guard let index = dataSource?.remove(viewModel) else { return }

        delete(section: index)
    }

    func willBeClosed() {
        delegate?.modalClosed()
    }
}
