//
//  OnboardingFeaturesView.swift
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
    static let pageControlHeight: CGFloat = 36.0
}

protocol FeaturesViewDelegate: class {
    func swipedToLastPage()
}

final class OnboardingFeaturesView: UIView {
    weak var delegate: FeaturesViewDelegate?

    private var collectionView: UICollectionView!
    private var pageControl = UIPageControl()

    private let images = [#imageLiteral(resourceName: "paymentsSecurity"), #imageLiteral(resourceName: "absoluteControl"), #imageLiteral(resourceName: "oneApp")]
    private let titles = [l10n(.firstFeature), l10n(.secondFeature), l10n(.thirdFeature)]
    private let descriptions = [
        l10n(.firstFeatureDescription),
        l10n(.secondFeatureDescription),
        l10n(.thirdFeatureDescription)
    ]

    init() {
        super.init(frame: .zero)
        setupCollectionView()
        setupPageControl()
        layout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension OnboardingFeaturesView {
    func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: FeaturesViewFlowLayout())
        collectionView.register(
            FeaturesCollectionViewCell.self, forCellWithReuseIdentifier: FeaturesCollectionViewCell.reuseIdentifier
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .white
    }

    func setupPageControl() {
        pageControl.numberOfPages = titles.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .auth_blue
        pageControl.pageIndicatorTintColor = .auth_lightGray50
    }
}

// MARK: - UICollectionViewDataSource
extension OnboardingFeaturesView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturesCollectionViewCell.reuseIdentifier,
                                                      for: indexPath) as! FeaturesCollectionViewCell
        // swiftlint:disable:previous force_cast

        cell.set(image: images[indexPath.row], title: titles[indexPath.row], description: descriptions[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension OnboardingFeaturesView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.size
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if collectionView.width > 0 {
            let page = Int(scrollView.contentOffset.x / collectionView.width)
            pageControl.currentPage = page
            if page == images.count - 1 {
                delegate?.swipedToLastPage()
            }
        }
    }
}

// MARK: - Layout
extension OnboardingFeaturesView: Layoutable {
    func layout() {
        addSubviews(collectionView, pageControl)

        collectionView.edges(to: self, insets: UIEdgeInsets(top: 0.0, left: 0.0, bottom: -Layout.pageControlHeight, right: 0.0))

        pageControl.centerX(to: collectionView)
        pageControl.height(Layout.pageControlHeight)
        pageControl.topToBottom(of: collectionView, offset: 10.0)
    }
}

private final class FeaturesViewFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        scrollDirection = .horizontal
        minimumInteritemSpacing = 0.0
        minimumLineSpacing = 0.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
