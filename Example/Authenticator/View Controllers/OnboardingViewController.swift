//
//  ViewController.swift
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
import TinyConstraints

private struct Layout {
    static let pageControlTopOffset: CGFloat = AppLayout.screenHeight * 0.47
    static let pageLeftOffset: CGFloat = 32.0
    static let pageControlHeight: CGFloat = 8.0
    static let buttonHeight: CGFloat = 48.0
    static let buttonStackViewBottomOffset: CGFloat = 8.0
    static let buttonStackViewSideOffset: CGFloat = 32.0
}

final class OnboardingViewController: BaseViewController {
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: FeaturesViewFlowLayout())
    private var pageControl = UIPageControl()

    private let skipButton = UIButton(frame: .zero)
    private let actionButton = CustomButton(.filled, text: l10n(.next))

    private var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 0.0
        return stackView
    }()
    private let contatiner = UIView()

    private let viewModel = OnboardingViewControllerViewModel()

    var donePressedClosure: (() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = viewModel.backgroundColor
        setupCollectionView()
        setupPageControl()
        setupButtons()
        handleState()
        layout()
    }

    @objc func getStartedPressed() {
        donePressedClosure?()
    }

    @objc func nextPressed() {
        viewModel.didPressedNext()
    }

    func handleState() {
        viewModel.state.valueChanged = { value in
            switch value {
            case .swipedAt(let number):
                self.pageControl.currentPage = number
            case .showPage(let number):
                self.pageControl.currentPage = number
                self.collectionView.scrollToItem(
                    at: IndexPath(row: number, section: 0),
                    at: .centeredHorizontally,
                    animated: true
                )
            case .finish:
                self.pageControl.currentPage = self.viewModel.numberOfPages
                self.swipedToLastPage()
            default: break
            }
            self.viewModel.didChangePage()
        }
    }
}

// MARK: - Setup
private extension OnboardingViewController {
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

    func setupButtons() {
        skipButton.setTitle(l10n(.skip), for: .normal)
        skipButton.contentHorizontalAlignment = .left
        skipButton.setTitleColor(viewModel.titleColor, for: .normal)
        skipButton.titleLabel?.font = viewModel.buttonFont
        skipButton.addTarget(self, action: #selector(done), for: .touchUpInside)

        actionButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
    }
}

// MARK: - UICollectionViewDataSource
extension OnboardingViewController: UICollectionViewDataSource {
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
extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.size
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        viewModel.countLastPage(
            collectionViewWidth: collectionView.width,
            scrollViewContentXOffest: targetContentOffset.pointee.x
        )
    }
}

// MARK: - Actions
extension OnboardingViewController {
    @objc private func done() {
        donePressedClosure?()
    }
}

// MARK: - Layout
extension OnboardingViewController: Layoutable {
    func layout() {
        view.addSubviews(collectionView, pageControl, buttonsStackView)

        collectionView.top(to: view)
        collectionView.width(to: view)
        collectionView.centerX(to: view)
        collectionView.bottomToTop(of: buttonsStackView)

        pageControl.top(to: collectionView, offset: Layout.pageControlTopOffset)
        pageControl.left(to: collectionView, offset: Layout.pageLeftOffset)
        pageControl.height(Layout.pageControlHeight)

        buttonsStackView.addArrangedSubviews(skipButton, actionButton)

        buttonsStackView.bottom(
            to: view, view.safeAreaLayoutGuide.bottomAnchor,
            offset: -Layout.buttonStackViewBottomOffset
        )
        buttonsStackView.left(to: view, offset: Layout.buttonStackViewSideOffset)
        buttonsStackView.right(to: view, offset: -Layout.buttonStackViewSideOffset)
        buttonsStackView.height(Layout.buttonHeight)
    }
}

// MARK: - FeaturesViewDelegate
extension OnboardingViewController {
    func swipedToLastPage() {
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 1.0,
            options: [],
            animations: {
                self.skipButton.isHidden = true
                self.actionButton.setTitle(l10n(.getStarted), for: .normal)
            }
        )
        actionButton.removeTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(getStartedPressed), for: .touchUpInside)
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
