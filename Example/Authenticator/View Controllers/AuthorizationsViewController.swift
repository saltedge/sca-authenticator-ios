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
    func refreshPressed()
    func selectedViewModel(at index: Int)
    func denyPressed(at index: Int)
    func confirmPressed(at index: Int, cell: AuthorizationCollectionViewCell)
    func modalClosed()
}

final class AuthorizationsViewController: BaseViewController {
    private let authorizationsView = MainAuthorizationsView()

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
        view.backgroundColor = .auth_backgroundColor
        authorizationsView.backgroundColor = .white
        setupNavigationItems()
        setupObservers()
        layout()
        noDataView.alpha = 1.0
    }

    func reloadData() {
        authorizationsView.dataSource = dataSource
        authorizationsView.reloadData()
    }

    @objc func refresh() {
        delegate?.refreshPressed()
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
    func setupNavigationItems() {
        navigationItem.title = "Authorizations"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "Sync"),
            style: .plain,
            target: self,
            action: #selector(refresh)
        )
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
                self?.authorizationsView.alpha = !dataSource.hasDataToShow ? 0.0 : 1.0
            }
        )
    }
}

// MARK: - Actions
extension AuthorizationsViewController {
    func delete(section: Int) {
        updateViewsHiddenState()
    }
}

// MARK: - Layout
extension AuthorizationsViewController: Layoutable {
    func layout() {
        view.addSubviews(authorizationsView, noDataView)

        authorizationsView.edgesToSuperview()

        noDataView.left(to: view, offset: AppLayout.sideOffset)
        noDataView.right(to: view, offset: -AppLayout.sideOffset)
        noDataView.center(in: view)
    }
}

// MARK: - AuthorizationHeaderSwipingViewDelegate
extension AuthorizationsViewController: AuthorizationHeaderSwipingViewDelegate {
    func timerExpired() {
//        guard let dataSource = self.dataSource else { return }
//        dataSource.remove(<#T##viewModel: AuthorizationViewModel##AuthorizationViewModel#>)
    }
}
