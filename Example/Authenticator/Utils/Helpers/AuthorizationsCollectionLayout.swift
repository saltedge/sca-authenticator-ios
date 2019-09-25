//
//  AuthorizationsCollectionLayout
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

final class AuthorizationsCollectionLayout: UICollectionViewFlowLayout {
    private var previousOffset: CGFloat = 0
    private var currentPage: Int = 0

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }

        let halfWidth = collectionView.bounds.width / 2
        let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth

        let layoutAttributes = layoutAttributesForElements(in: collectionView.bounds)

        let comparator: (UICollectionViewLayoutAttributes, UICollectionViewLayoutAttributes) -> (Bool) = { first, second in
            return abs(first.center.x - proposedContentOffsetCenterX) < abs(second.center.x - proposedContentOffsetCenterX)
        }

        let closest = layoutAttributes?.sorted { comparator($0, $1) }.first ?? UICollectionViewLayoutAttributes()

        return CGPoint(x: closest.center.x - halfWidth, y: proposedContentOffset.y)
    }
}

final class HeaderCollectionLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let inset: Int = 16

        let vcBounds = self.collectionView!.bounds

        var candidateContentOffsetX: CGFloat = proposedContentOffset.x

        for attributes in self.layoutAttributesForElements(in: vcBounds)! as [UICollectionViewLayoutAttributes] {
            if vcBounds.origin.x < attributes.center.x {
                candidateContentOffsetX = attributes.frame.origin.x - CGFloat(inset)
                break
            }
        }

        return CGPoint(x: candidateContentOffsetX, y: proposedContentOffset.y)
    }
}
