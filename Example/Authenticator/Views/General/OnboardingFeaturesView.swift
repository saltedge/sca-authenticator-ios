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
    static let pageControlTopOffset: CGFloat = AppLayout.screenHeight * 0.47
    static let pageLeftOffset: CGFloat = 32.0
    static let pageControlHeight: CGFloat = 8.0
}

protocol FeaturesViewDelegate: class {
    func swipedToLastPage()
}

final class OnboardingFeaturesView: UIView {
    weak var delegate: FeaturesViewDelegate?

    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: FeaturesViewFlowLayout())
    private var pageControl = UIPageControl()

    private let viewModel = FeatureViewViewModel()

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
        collectionView.backgroundColor = viewModel.backgroundColor
    }

    func setupPageControl() {
        pageControl.numberOfPages = viewModel.numberOfPages
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = viewModel.indicatorColor
        pageControl.pageIndicatorTintColor = viewModel.pageindicatorTintColor
    }
}

// MARK: - UICollectionViewDataSource
extension OnboardingFeaturesView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfPages
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FeaturesCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! FeaturesCollectionViewCell // swiftlint:disable:this force_cast

        let cellViewModel = FeatureCellViewModel(item: viewModel.item(at: indexPath))
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
        viewModel.countLastPage(
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
        collectionView.bottom(to: self)

        pageControl.top(to: self, offset: Layout.pageControlTopOffset)
        pageControl.left(to: self, offset: Layout.pageLeftOffset)
        pageControl.height(Layout.pageControlHeight)
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
