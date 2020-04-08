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

    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: FeaturesViewFlowLayout())
    private var pageControl = UIPageControl()

    private let featureListViewModel = FeatureViewViewModel()

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
        pageControl.numberOfPages = featureListViewModel.numberOfPages
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = FeatureViewViewModel.Style.indicatorColor
        pageControl.pageIndicatorTintColor = FeatureViewViewModel.Style.pageindicatorTintColor
    }
}

// MARK: - UICollectionViewDataSource
extension OnboardingFeaturesView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return featureListViewModel.numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return featureListViewModel.numberOfPages
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FeaturesCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! FeaturesCollectionViewCell // swiftlint:disable:this force_cast

        let cellViewModel = FeatureCellViewModel(item: featureListViewModel.item(at: indexPath))
        cell.viewModel = cellViewModel

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
        featureListViewModel.countLastPage(
            collectionViewWidth: collectionView.width,
            scrollViewContentXOffest: scrollView.contentOffset.x,
            pageControl: pageControl,
            completion: {
                delegate?.swipedToLastPage()
            }
        )
    }
}

// MARK: - Layout
extension OnboardingFeaturesView: Layoutable {
    func layout() {
        addSubviews(collectionView, pageControl)

        collectionView.top(to: self)
        collectionView.width(to: self)
        collectionView.centerX(to: self)
        collectionView.bottomToTop(of: pageControl)

        pageControl.centerX(to: self)
        pageControl.height(Layout.pageControlHeight)
        pageControl.bottom(to: self)
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
