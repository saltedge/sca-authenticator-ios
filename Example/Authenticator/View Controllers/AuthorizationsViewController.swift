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
    func showMoreOptionsMenu()
}

final class AuthorizationsViewController: BaseViewController {
    private let authorizationView = AuthorizationView()
    private let moreButton = UIButton()
    private let qrButton = UIButton()
    private var messageBarView: MessageBarView?
    private var noDataView: NoDataView?

    weak var delegate: AuthorizationsViewControllerDelegate?

    var viewModel: AuthorizationsViewModel! {
        didSet {
            authorizationView.viewModel = viewModel
            handleViewModelState()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = l10n(.authenticator)
        view.backgroundColor = .backgroundColor
        setupObservers()
        setupNoDataView()
        layout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavigationBarButtons()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        [moreButton, qrButton].forEach { $0.removeFromSuperview() }
    }

    private func handleViewModelState() {
        viewModel.state.valueChanged = { [weak self] value in
            guard let strongSelf = self else { return }

            switch value {
            case .changedConnectionsData:
                strongSelf.noDataView?.updateContent(data: strongSelf.viewModel.emptyViewData)
            case .reloadData:
                strongSelf.authorizationView.reloadData()
                strongSelf.updateViewsHiddenState()
            case let .scrollTo(index):
                strongSelf.authorizationView.scroll(to: index)
            case let .presentFail(message):
                strongSelf.present(message: message, style: .error)
            case let .scanQrPressed(success):
                if success {
                    strongSelf.delegate?.scanQrPressed()
                } else {
                    strongSelf.showConfirmationAlert(
                        withTitle: l10n(.deniedCamera),
                        message: l10n(.deniedCameraDescription),
                        confirmActionTitle: l10n(.goToSettings),
                        confirmActionStyle: .default,
                        confirmAction: { _ in
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl)
                            }
                        }
                    )
                }
            default: break
            }
            strongSelf.viewModel.resetState()
        }
    }

    private func setupNoDataView() {
        noDataView = NoDataView(data: viewModel.emptyViewData, action: scanQrPressed)
    }

    @objc private func hasNoConnection() {
        messageBarView = present(message: l10n(.noInternetConnection), style: .warning, height: 60.0, hide: false)
    }

    @objc private func hasConnection() {
        if let messageBarView = messageBarView {
            dismiss(messageBarView: messageBarView)
        }
    }

    private func updateViewsHiddenState() {
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                guard let strongSelf = self else { return }

                strongSelf.noDataView?.alpha = strongSelf.viewModel.hasDataToShow ? 0.0 : 1.0
                strongSelf.authorizationView.alpha = !strongSelf.viewModel.hasDataToShow ? 0.0 : 1.0
            }
        )
    }

    deinit {
        NotificationsHelper.removeObserver(self)
    }
}

// MARK: - Setup
private extension AuthorizationsViewController {
    func setupNavigationBarButtons() {
        moreButton.setImage(UIImage(named: "more"), for: .normal)
        moreButton.addTarget(self, action: #selector(morePressed), for: .touchUpInside)

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
}

// MARK: - Actions
private extension AuthorizationsViewController {
    @objc func scanQrPressed() {
        viewModel.scanQrPressed()
    }

    @objc func morePressed() {
        delegate?.showMoreOptionsMenu()
    }

    func delete(section: Int) {
        updateViewsHiddenState()
    }
}

// MARK: - Layout
extension AuthorizationsViewController: Layoutable {
    func layout() {
        guard let noDataView = noDataView else { return }

        view.addSubviews(authorizationView, noDataView)

        authorizationView.edgesToSuperview()

        noDataView.topToSuperview(offset: AppLayout.screenHeight * 0.11)
        noDataView.widthToSuperview()
    }
}
