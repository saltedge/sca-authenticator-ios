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
    static let headerSize: CGSize = CGSize(width: AppLayout.screenWidth * 0.66, height: 42.0)
}

final class MainAuthorizationsView: UIView {
    private let headerSwipingView = AuthorizationsHeadersSwipingView()
    private let authorizationSwipingView = AuthorizationsCollectionSwipingView()

    var dataSource: AuthorizationsDataSource?

    init() {
        super.init(frame: .zero)
        headerSwipingView.collectionView.dataSource = self
        headerSwipingView.collectionView.delegate = self
        authorizationSwipingView.collectionView.dataSource = self
        authorizationSwipingView.collectionView.delegate = self

        setupPanGesture()
        layout()
    }

    func reloadData() {
        headerSwipingView.collectionView.reloadData()
        authorizationSwipingView.collectionView.reloadData()
    }

    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
    }
}

// MARK: - UICollectionViewDataSource
extension MainAuthorizationsView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSource = self.dataSource else { return 0 }

        return dataSource.rows()
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
                withReuseIdentifier: "AuthorizationHeaderCollectionViewCell",
                for: indexPath
                ) as? AuthorizationHeaderCollectionViewCell else { return UICollectionViewCell() }

            headerCell.configure(viewModel, at: indexPath)
            cell = headerCell
        } else {
            guard let authorizationCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "AuthorizationCollectionViewCell",
                for: indexPath
                ) as? AuthorizationCollectionViewCell else { return UICollectionViewCell() }

            authorizationCell.set(with: viewModel)
            cell = authorizationCell
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MainAuthorizationsView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let dataSource = self.dataSource,
            let viewModel = dataSource.viewModel(at: indexPath.row) else { return }

        print("Tapped model:", viewModel)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        guard collectionView == headerSwipingView.collectionView else { return .zero }

        let cellWidth: CGFloat = Layout.headerSize.width

        let numberOfCells = floor(frame.size.width / cellWidth)

        let edgeInsets = (frame.size.width - (numberOfCells * cellWidth)) / (numberOfCells + 1)

        return UIEdgeInsets(top: 0.0, left: edgeInsets, bottom: 0.0, right: edgeInsets)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == authorizationSwipingView.collectionView {
            return collectionView.size
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
        headerSwipingView.height(60.0)

        authorizationSwipingView.topToBottom(of: headerSwipingView)
        authorizationSwipingView.width(to: self)
        authorizationSwipingView.bottom(to: self, offset: -AppLayout.tabBarHeight)
    }
}
