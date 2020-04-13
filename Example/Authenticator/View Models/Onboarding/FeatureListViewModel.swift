//
//  FeatureViewViewModel
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2020 Salt Edge Inc.
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

struct FeatureViewViewModel {
    private let images = [#imageLiteral(resourceName: "paymentsSecurity"), #imageLiteral(resourceName: "absoluteControl"), #imageLiteral(resourceName: "oneApp")]
    private let titles = [l10n(.firstFeature), l10n(.secondFeature), l10n(.thirdFeature)]
    private let descriptions = [
        l10n(.firstFeatureDescription),
        l10n(.secondFeatureDescription),
        l10n(.thirdFeatureDescription)
    ]

    var features: [OnboardingItem] {
        return images.enumerated().map { index, value in
            return (value, titles[index], descriptions[index])
        }
    }

    var numberOfPages: Int {
        return titles.count
    }

    var numberOfSections: Int = 1

    func item(at indexPath: IndexPath) -> OnboardingItem {
        return features[indexPath.row]
    }

    func countLastPage(
        collectionViewWidth: CGFloat,
        scrollViewContentXOffest: CGFloat,
        pageControl: UIPageControl,
        completion: () -> ()
    ) {
        if collectionViewWidth > 0 {
            let page = Int(scrollViewContentXOffest / collectionViewWidth)
            pageControl.currentPage = page
            if page == numberOfPages - 1 {
                completion()
            }
        }
    }

    // MARK: - Style
    let backgroundColor: UIColor = .backgroundColor
    let indicatorColor: UIColor = .lightBlue
    let pageindicatorTintColor: UIColor = .lightGray
}
