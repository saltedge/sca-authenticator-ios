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
    func scanQrPressed()
}

final class AuthorizationsViewController: BaseViewController {
    private let authorizationsView = MainAuthorizationsView()
    private var messageBarView: MessageBarView?
    private var noDataView: AuthorizationsNoDataView?

    weak var delegate: AuthorizationsViewControllerDelegate?

    var dataSource: AuthorizationsDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = l10n(.authenticator)
        view.backgroundColor = .backgroundColor
        authorizationsView.backgroundColor = .white
        authorizationsView.delegate = self
        setupNavigationBarButtons()
        setupObservers()
        setupNoDataView()
        layout()
    }

    private func setupNoDataView() {
        noDataView = AuthorizationsNoDataView(
            type: dataSource.hasConnections ? .noAuthorizations : .noConnections,
            buttonAction: scanQrPressed
        )
    }

    func reloadData(at index: Int) {
        authorizationsView.reloadData(at: index)
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
    func setupNavigationBarButtons() {
        let moreButton = UIButton()
        moreButton.setImage(UIImage(named: "more"), for: .normal)
        moreButton.addTarget(self, action: #selector(morePressed), for: .touchUpInside)

        let qrButton = UIButton()
        qrButton.setImage(UIImage(named: "qr"), for: .normal)
        qrButton.addTarget(self, action: #selector(scanQrPressed), for: .touchUpInside)

        navigationController?.navigationBar.addSubviews(moreButton, qrButton)

        moreButton.size(CGSize(width: 22.0, height: 22.0))
        moreButton.rightToSuperview(offset: -16.0)
        moreButton.bottomToSuperview(offset: -12.0)

        qrButton.size(CGSize(width: 22.0, height: 22.0))
        qrButton.rightToLeft(of: moreButton, offset: -30.0)
        qrButton.bottomToSuperview(offset: -12.0)
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
                guard let strongSelf = self else { return }

                strongSelf.noDataView?.type = strongSelf.dataSource.hasConnections ? .noAuthorizations : .noConnections
                strongSelf.noDataView?.alpha = strongSelf.dataSource.hasDataToShow ? 0.0 : 1.0
                strongSelf.authorizationsView.alpha = !strongSelf.dataSource.hasDataToShow ? 0.0 : 1.0
            }
        )
    }
}

// MARK: - Actions
private extension AuthorizationsViewController {
    @objc func scanQrPressed() {
        delegate?.scanQrPressed()
    }

    // TODO: Replace with presenting action sheet
    @objc func morePressed() {
        print("More pressed")
    }

    func delete(section: Int) {
        updateViewsHiddenState()
    }

    func confirmAuthorization(by authorizationId: String) {
        guard let data = dataSource.confirmationData(for: authorizationId),
            let viewModel = dataSource.viewModel(with: authorizationId),
            let index = dataSource.index(of: viewModel) else { return }

        viewModel.state = .processing
        authorizationsView.reloadData(at: index)

        AuthorizationsInteractor.confirm(
            data: data,
            success: { [weak self] in
                viewModel.state = .success
                viewModel.actionTime = Date()
                self?.authorizationsView.reloadData(at: index)
            },
            failure: { [weak self] _ in
                viewModel.state = .undefined
                viewModel.actionTime = Date()
                self?.authorizationsView.reloadData(at: index)
            }
        )
    }
}

// MARK: - Layout
extension AuthorizationsViewController: Layoutable {
    func layout() {
        guard let noDataView = noDataView else { return }

        view.addSubviews(authorizationsView, noDataView)

        authorizationsView.edgesToSuperview()
        noDataView.topToSuperview(offset: 100)
        noDataView.widthToSuperview()
    }
}

// MARK: - Network
extension AuthorizationsViewController: MainAuthorizationsViewDelegate {
    func denyPressed(authorizationId: String) {
        guard let data = dataSource.confirmationData(for: authorizationId),
            let viewModel = dataSource.viewModel(with: authorizationId),
            let index = dataSource.index(of: viewModel) else { return }

        viewModel.state = .processing
        authorizationsView.reloadData(at: index)

        AuthorizationsInteractor.deny(
            data: data,
            success: {
                viewModel.state = .denied
                viewModel.actionTime = Date()
                self.authorizationsView.reloadData(at: index)
            },
            failure: { _ in
                viewModel.state = .undefined
                viewModel.actionTime = Date()
                self.authorizationsView.reloadData(at: index)
            }
        )
    }

    func confirmPressed(authorizationId: String) {
        confirmAuthorization(by: authorizationId)
    }
}
