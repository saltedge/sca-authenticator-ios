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

final class AuthorizationsViewController: BaseViewController {
    private let authorizationsView = MainAuthorizationsView()

    private let noDataView = NoDataView(
        image: #imageLiteral(resourceName: "no_authorizations"),
        title: l10n(.noAuthorizations),
        description: l10n(.noAuthorizationsDescription)
    )

    private var messageBarView: MessageBarView?

    var dataSource: AuthorizationsDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = l10n(.authorizations)
        view.backgroundColor = .auth_backgroundColor
        authorizationsView.backgroundColor = .white
        authorizationsView.delegate = self
        setupObservers()
        layout()
        noDataView.alpha = 1.0
    }

    func reloadData() {
        authorizationsView.dataSource = dataSource
        authorizationsView.reloadData()
    }

    func scroll(to index: Int) {
        authorizationsView.scroll(to: index)
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

    func presentPasscodeView() {
        let passcodeCoordinator = PasscodeCoordinator(
            rootViewController: self,
            purpose: .enter,
            type: .authorize
        )
        passcodeCoordinator.onCompleteClosure = { [weak self] in
            //self?.selectedCell?.setProcessing(with: l10n(.processing))

            guard let index = self?.authorizationsView.focusIndexPath,
                let data = self?.dataSource?.confirmationData(for: index.row) else { return }

            AuthorizationsInteractor.confirm(data: data)
        }
        passcodeCoordinator.start()
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

// MARK: - Network
extension AuthorizationsViewController: MainAuthorizationsViewDelegate {
    func denyPressed(at index: Int) {
        guard let data = dataSource?.confirmationData(for: index) else { return }

        AuthorizationsInteractor.deny(data: data)
    }

    func confirmPressed(at index: Int, cell: AuthorizationCollectionViewCell) {
        guard PasscodeManager.isBiometricsEnabled else { self.presentPasscodeView(); return }

        PasscodeManager.useBiometrics(
            type: .authorize,
            reasonString: "Confirm authorization",
            onSuccess: {
                cell.setProcessing(with: l10n(.processing))

                guard let data = self.dataSource?.confirmationData(for: index) else { return }

                AuthorizationsInteractor.confirm(data: data)
            },
            onFailure: { _ in
                self.presentPasscodeView()
            }
        )
    }
}
