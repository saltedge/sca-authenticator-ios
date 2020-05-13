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
}

final class AuthorizationsHeadersSwipingView: UIView {
    private(set) var collectionView: UICollectionView

    init() {
        let flowLayout = AuthorizationsCollectionLayout()
        flowLayout.itemSize = CGSize(width: AppLayout.screenWidth * 0.66, height: 48.0)
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
        collectionView.register(
            AuthorizationHeaderCollectionViewCell.self,
            forCellWithReuseIdentifier: String(describing: AuthorizationHeaderCollectionViewCell.self)
        )
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .backgroundColor
    }
}

// MARK: - Layout
extension AuthorizationsHeadersSwipingView: Layoutable {
    func layout() {
        addSubview(collectionView)

        collectionView.edges(to: self)
    }
}
