//
//  OnboardingViewControllerViewModel
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

enum OnboardingViewControllerViewState: Equatable {
    case showPage(_ pageNumber: Int)
    case swipedAt(_ pageNumber: Int)
    case finish
    case normal

    static func == (lhs: OnboardingViewControllerViewState, rhs: OnboardingViewControllerViewState) -> Bool {
        switch (lhs, rhs) {
        case (.finish, .finish), (.normal, .normal):
            return true
        case let (.showPage(page1), .showPage(page2)), let (.swipedAt(page1), .swipedAt(page2)):
            return page1 == page2
        default: return false
        }
    }
}

class OnboardingViewControllerViewModel {
    var state = Observable<OnboardingViewControllerViewState>(.normal)

    private let images = [#imageLiteral(resourceName: "paymentsSecurity"), #imageLiteral(resourceName: "absoluteControl"), #imageLiteral(resourceName: "oneApp")]
    private let titles = [l10n(.firstFeature), l10n(.secondFeature), l10n(.thirdFeature)]
    private let descriptions = [
        l10n(.firstFeatureDescription),
        l10n(.secondFeatureDescription),
        l10n(.thirdFeatureDescription)
    ]

    private var currentPage: Int = 0

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

    func didPressedNext() {
        guard state.value == .normal, currentPage < 2 else { return }

        currentPage += 1

        state.value = .showPage(currentPage)

        if currentPage == numberOfPages - 1 {
            state.value = .finish
        }
    }

    func didChangePage() {
        state.value = .normal
    }

    func countLastPage(collectionViewWidth: CGFloat, scrollViewContentXOffest: CGFloat) {
        guard collectionViewWidth != 0.0 else { return }

        let page = Int(scrollViewContentXOffest / collectionViewWidth)

        if page == numberOfPages - 1 {
            state.value = .finish
        } else {
            state.value = .swipedAt(page)
        }
    }

    // MARK: - Style
    let backgroundColor: UIColor = .backgroundColor
    let indicatorColor: UIColor = .lightBlue
    let pageindicatorTintColor: UIColor = .lightGray

    let titleColor: UIColor = .lightBlue
    let buttonFont: UIFont = .systemFont(ofSize: 18.0, weight: .medium)
}
