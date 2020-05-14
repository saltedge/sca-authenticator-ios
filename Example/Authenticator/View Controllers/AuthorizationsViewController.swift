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

private struct Layout {
    static let headerSpacing: CGFloat = 16.0
    static let headerSize: CGSize = CGSize(width: AppLayout.screenWidth * 0.66, height: 42.0)
    static let headerSwipingViewHeight: CGFloat = 60.0
}

final class AuthorizationsViewController: BaseViewController {
    private let headerSwipingView = AuthorizationsHeadersSwipingView()
    private let authorizationCollectionView: UICollectionView = {
        let flowLayout = AuthorizationsCollectionLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0.0
        return UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    }()
    private var messageBarView: MessageBarView?
    private var noDataView: AuthorizationsNoDataView?

    weak var delegate: AuthorizationsViewControllerDelegate?

    var dataSource: AuthorizationsDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = l10n(.authenticator)
        view.backgroundColor = .backgroundColor
        setupSwipingViews()
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
        authorizationCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }

    func reloadData() {
        headerSwipingView.collectionView.reloadData()
        authorizationCollectionView.reloadData()
    }

    func scroll(to index: Int) {
        headerSwipingView.collectionView.scrollToItem(
            at: IndexPath(item: index, section: 0),
            at: .centeredHorizontally,
            animated: false
        )
        authorizationCollectionView.scrollToItem(
            at: IndexPath(item: index, section: 0),
            at: .centeredHorizontally,
            animated: false
        )
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

    func updateViewsHiddenState() {
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                guard let strongSelf = self else { return }

                strongSelf.noDataView?.type = strongSelf.dataSource.hasConnections ? .noAuthorizations : .noConnections
                strongSelf.noDataView?.alpha = strongSelf.dataSource.hasDataToShow ? 0.0 : 1.0
                [strongSelf.headerSwipingView, strongSelf.authorizationCollectionView]
                    .forEach { $0.alpha = !strongSelf.dataSource.hasDataToShow ? 0.0 : 1.0 }
            }
        )
    }
}

// MARK: - Setup
private extension AuthorizationsViewController {
    func setupSwipingViews() {
        headerSwipingView.collectionView.dataSource = self
        headerSwipingView.collectionView.delegate = self

        authorizationCollectionView.dataSource = self
        authorizationCollectionView.delegate = self
        authorizationCollectionView.backgroundColor = .clear
        authorizationCollectionView.register(
            AuthorizationCollectionViewCell.self,
            forCellWithReuseIdentifier: String(describing: AuthorizationCollectionViewCell.self)
        )
        authorizationCollectionView.isPagingEnabled = true
        authorizationCollectionView.showsHorizontalScrollIndicator = false
    }

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
}

// MARK: - UICollectionViewDataSource
extension AuthorizationsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSource = self.dataSource else { return 0 }

        return dataSource.rows
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let dataSource = self.dataSource else { return 0 }

        return dataSource.sections
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = self.dataSource,
            let viewModel = dataSource.viewModel(at: indexPath.row) else { return UICollectionViewCell() }

        var cell: UICollectionViewCell

        if collectionView == headerSwipingView.collectionView {
            guard let headerCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: AuthorizationHeaderCollectionViewCell.self),
                for: indexPath
            ) as? AuthorizationHeaderCollectionViewCell else { return UICollectionViewCell() }

            headerCell.delegate = self
            headerCell.viewModel = viewModel
            cell = headerCell
        } else {
            guard let authorizationCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: AuthorizationCollectionViewCell.self),
                for: indexPath
            ) as? AuthorizationCollectionViewCell else { return UICollectionViewCell() }

            authorizationCell.set(with: viewModel)
            authorizationCell.backgroundColor = .clear
            authorizationCell.delegate = self
            cell = authorizationCell
        }

        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let authorizationCellWidth = AppLayout.screenWidth
        let headerPlusSpace = Layout.headerSize.width + Layout.headerSpacing
        let authorizationXOffset = authorizationCollectionView.contentOffset.x

        let page = floor(authorizationXOffset / authorizationCellWidth)
        let pagePercent = (authorizationXOffset - (page * authorizationCellWidth)) / authorizationCellWidth

        headerSwipingView.collectionView.contentOffset.x = (page * headerPlusSpace - 8.0) + (headerPlusSpace * pagePercent)
    }
}

// MARK: - UICollectionViewDelegate
extension AuthorizationsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == headerSwipingView.collectionView {
            headerSwipingView.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            authorizationCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == headerSwipingView.collectionView {
            let inset = 0.16 * AppLayout.screenWidth

            return UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: inset)
        } else {
            return UIEdgeInsets(top: 60.0, left: 0.0, bottom: 0.0, right: 0.0)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == authorizationCollectionView {
            return CGSize(width: collectionView.size.width, height: collectionView.size.height - 60.0)
        } else {
            return Layout.headerSize
        }
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
        reloadData(at: index)

        AuthorizationsInteractor.confirm(
            data: data,
            success: { [weak self] in
                viewModel.state = .success
                viewModel.actionTime = Date()
                self?.reloadData(at: index)
            },
            failure: { [weak self] _ in
                viewModel.state = .undefined
                viewModel.actionTime = Date()
                self?.reloadData(at: index)
            }
        )
    }
}

// MARK: - Layout
extension AuthorizationsViewController: Layoutable {
    func layout() {
        guard let noDataView = noDataView else { return }

        view.addSubviews(headerSwipingView, authorizationCollectionView, noDataView)

        headerSwipingView.topToSuperview()
        headerSwipingView.widthToSuperview()
        headerSwipingView.height(Layout.headerSwipingViewHeight)
        headerSwipingView.centerX(to: view)
        view.sendSubviewToBack(headerSwipingView)

        authorizationCollectionView.edgesToSuperview()

        noDataView.topToSuperview(offset: 100)
        noDataView.widthToSuperview()
    }
}

// MARK: - AuthorizationCellDelegate
extension AuthorizationsViewController: AuthorizationCellDelegate {
    func confirmPressed(_ authorizationId: String) {
        confirmAuthorization(by: authorizationId)
    }

    func denyPressed(_ authorizationId: String) {
        guard let data = dataSource.confirmationData(for: authorizationId),
            let viewModel = dataSource.viewModel(with: authorizationId),
            let index = dataSource.index(of: viewModel) else { return }

        viewModel.state = .processing
        reloadData(at: index)

        AuthorizationsInteractor.deny(
            data: data,
            success: {
                viewModel.state = .denied
                viewModel.actionTime = Date()
                self.reloadData(at: index)
            },
            failure: { _ in
                viewModel.state = .undefined
                viewModel.actionTime = Date()
                self.reloadData(at: index)
            }
        )
    }
}

// MARK: - AuthorizationHeaderCollectionViewCellDelegates
extension AuthorizationsViewController: AuthorizationHeaderCollectionViewCellDelegate {
    func timerExpired(_ cell: AuthorizationHeaderCollectionViewCell) {
        guard let indexPath = headerSwipingView.collectionView.indexPath(for: cell) else { return }

        headerSwipingView.collectionView.reloadItems(at: [indexPath])
        authorizationCollectionView.reloadItems(at: [indexPath])
    }
}
