//
//  MainAuthorizationsView
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

private struct Layout {
    static let headerSpacing: CGFloat = 16.0
    static let headerSize: CGSize = CGSize(width: AppLayout.screenWidth * 0.66, height: 42.0)
    static let headerSwipingViewHeight: CGFloat = 60.0
}

protocol MainAuthorizationsViewDelegate: class {
    func confirmPressed(at index: Int, cell: AuthorizationCollectionViewCell)
    func denyPressed(at index: Int)
}

final class MainAuthorizationsView: UIView {
    private let headerSwipingView = AuthorizationsHeadersSwipingView()
    private let authorizationSwipingView = SwipingAuthorizationsCollectionView()

    var dataSource: AuthorizationsDataSource?

    weak var delegate: MainAuthorizationsViewDelegate?

    init() {
        super.init(frame: .zero)
        setupSwipingViews()
        layout()
    }

    func reloadData() {
        headerSwipingView.collectionView.reloadData()
        authorizationSwipingView.collectionView.reloadData()
    }

    func scroll(to index: Int) {
        headerSwipingView.collectionView.scrollToItem(
            at: IndexPath(item: index, section: 0),
            at: .centeredHorizontally,
            animated: false
        )
        authorizationSwipingView.collectionView.scrollToItem(
            at: IndexPath(item: index, section: 0),
            at: .centeredHorizontally,
            animated: false
        )
    }

    func remove(at index: Int) {
        headerSwipingView.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
        authorizationSwipingView.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
        reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension MainAuthorizationsView {
    func setupSwipingViews() {
        headerSwipingView.collectionView.dataSource = self
        headerSwipingView.collectionView.delegate = self
        authorizationSwipingView.collectionView.dataSource = self
        authorizationSwipingView.collectionView.delegate = self
        authorizationSwipingView.backgroundColor = .clear
    }
}

// MARK: - UICollectionViewDataSource
extension MainAuthorizationsView: UICollectionViewDataSource {
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
            headerCell.configure(viewModel, at: indexPath)
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
        let authorizationXOffset = authorizationSwipingView.collectionView.contentOffset.x

        let page = floor(authorizationXOffset / authorizationCellWidth)
        let pagePercent = (authorizationXOffset - (page * authorizationCellWidth)) / authorizationCellWidth

        headerSwipingView.collectionView.contentOffset.x = (page * headerPlusSpace - 8.0) + (headerPlusSpace * pagePercent)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        AppDelegate.main.authorizationIdFromPush = nil
    }
}

// MARK: - UICollectionViewDelegate
extension MainAuthorizationsView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
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
        if collectionView == authorizationSwipingView.collectionView {
            return CGSize(width: collectionView.size.width, height: collectionView.size.height - 60.0)
        } else {
            return Layout.headerSize
        }
    }
}

// MARK: - Layout
extension MainAuthorizationsView: Layoutable {
    func layout() {
        addSubviews(headerSwipingView, authorizationSwipingView)

        headerSwipingView.topToSuperview()
        headerSwipingView.widthToSuperview()
        headerSwipingView.height(Layout.headerSwipingViewHeight)
        headerSwipingView.centerX(to: self)
        sendSubviewToBack(headerSwipingView)

        authorizationSwipingView.topToSuperview()
        authorizationSwipingView.width(to: self)
        authorizationSwipingView.bottom(to: self)
        authorizationSwipingView.centerX(to: self)
    }
}

// MARK: - AuthorizationCellDelegate
extension MainAuthorizationsView: AuthorizationCellDelegate {
    func confirmPressed(_ cell: AuthorizationCollectionViewCell) {
        guard let indexPath = authorizationSwipingView.collectionView.indexPath(for: cell) else { return }

        delegate?.confirmPressed(at: indexPath.row, cell: cell)
    }

    func denyPressed(_ cell: AuthorizationCollectionViewCell) {
        guard let indexPath = authorizationSwipingView.collectionView.indexPath(for: cell) else { return }

        delegate?.denyPressed(at: indexPath.row)
    }
}

// MARK: - AuthorizationHeaderCollectionViewCellDelegates
extension MainAuthorizationsView: AuthorizationHeaderCollectionViewCellDelegate {
    func timerExpired(_ cell: AuthorizationHeaderCollectionViewCell) {
        guard let indexPath = headerSwipingView.collectionView.indexPath(for: cell),
            let viewModel = dataSource?.viewModel(at: indexPath.row) else { return }

        _ = dataSource?.remove(viewModel)
        remove(at: indexPath.row)
    }
}
