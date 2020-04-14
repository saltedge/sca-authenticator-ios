//
//  OnboardingViewModel
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

enum OnboardingViewState: Equatable {
    case showPage(_ pageNumber: Int)
    case swipedAt(_ pageNumber: Int)
    case finish
    case normal

    static func == (lhs: OnboardingViewState, rhs: OnboardingViewState) -> Bool {
        switch (lhs, rhs) {
        case (.finish, .finish), (.normal, .normal):
            return true
        case let (.showPage(page1), .showPage(page2)), let (.swipedAt(page1), .swipedAt(page2)):
            return page1 == page2
        default: return false
        }
    }
}

class OnboardingViewModel {
    var state = Observable<OnboardingViewState>(.normal)

    // TODO: Replace with correct images when available
    private let images = [
        UIImage(named: "absoluteControl", in: .authenticator_main, compatibleWith: nil)!,
        UIImage(named: "oneApp", in: .authenticator_main, compatibleWith: nil)!,
        UIImage(named: "paymentsSecurity", in: .authenticator_main, compatibleWith: nil)!
    ]
    private let titles = [l10n(.firstFeature), l10n(.secondFeature), l10n(.thirdFeature)]
    private let descriptions = [
        l10n(.firstFeatureDescription),
        l10n(.secondFeatureDescription),
        l10n(.thirdFeatureDescription)
    ]

    private var currentPage: Int = 0

    var features: [OnboardingCellViewModel] {
        return images.enumerated().map { index, image in
            return OnboardingCellViewModel(image: image, title: titles[index], description: descriptions[index])
        }
    }

    var numberOfPages: Int {
        return titles.count
    }

    var numberOfSections: Int = 1

    func item(at indexPath: IndexPath) -> OnboardingCellViewModel {
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

        currentPage = page

        if page == numberOfPages - 1 {
            state.value = .finish
        } else {
            state.value = .swipedAt(page)
        }
    }

    func resetCurrentPage() {
        currentPage = 0
    }

    // MARK: - Style
    let backgroundColor: UIColor = .backgroundColor
    let indicatorColor: UIColor = .lightBlue
    let pageIndicatorTintColor: UIColor = .lightGray
    let titleColor: UIColor = .lightBlue

    let buttonFont: UIFont = .systemFont(ofSize: 18.0, weight: .medium)
}
