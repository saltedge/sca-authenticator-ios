//
//  AuthorizationsHeadersSwipingView
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
    static let spacing: CGFloat = 16.0
    static let cellSize: CGSize = CGSize(width: AppLayout.screenWidth * 0.66, height: 42.0)
}

protocol AuthorizationHeaderSwipingViewDelegate: class {
    func timerExpired()
}

final class AuthorizationsHeadersSwipingView: UIView {
    private var collectionView: UICollectionView

    var dataSource: AuthorizationsDataSource?

    weak var delegate: AuthorizationHeaderSwipingViewDelegate?

    init() {
        let flowLayout = AuthorizationsCollectionLayout()
        flowLayout.itemSize = Layout.cellSize
        flowLayout.minimumLineSpacing = Layout.spacing
        flowLayout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        super.init(frame: .zero)
        setupCollectionView()
        layout()
    }

    func reloadData() {
        collectionView.reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension AuthorizationsHeadersSwipingView {
    func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.register(
            AuthorizationHeaderCollectionViewCell.self,
            forCellWithReuseIdentifier: "AuthorizationHeaderCollectionViewCell"
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: Layout.spacing, bottom: 0, right: Layout.spacing)
        collectionView.showsHorizontalScrollIndicator = false
    }
}

extension AuthorizationsHeadersSwipingView: UICollectionViewDataSource {
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

        guard let headerCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "AuthorizationHeaderCollectionViewCell",
            for: indexPath
        ) as? AuthorizationHeaderCollectionViewCell else { return UICollectionViewCell() }

        headerCell.configure(viewModel, at: indexPath)
        headerCell.delegate = self

        return headerCell
    }
}

extension AuthorizationsHeadersSwipingView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
        let cellWidth: CGFloat = Layout.cellSize.width

        let numberOfCells = floor(frame.size.width / cellWidth)

        let edgeInsets = (frame.size.width - (numberOfCells * cellWidth)) / (numberOfCells + 1)

        return UIEdgeInsets(top: 0.0, left: edgeInsets, bottom: 0.0, right: edgeInsets)
    }
}

// MARK: - Layout
extension AuthorizationsHeadersSwipingView: Layoutable {
    func layout() {
        addSubview(collectionView)

        collectionView.edges(to: self)
    }
}

// MARK: - AuthorizationHeaderCellDelegate
extension AuthorizationsHeadersSwipingView: AuthorizationHeaderCellDelegate {
    func timerExpired(cell: AuthorizationHeaderCollectionViewCell) {
        delegate?.timerExpired()
    }
}
