//
//  MainAuthorizationsView
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
    static let headerSpacing: CGFloat = 32.0
    static let headerMultiplier: CGFloat = (Layout.headerSize.width + Layout.headerSpacing) / AppLayout.screenWidth
    static let authorizationMultiplier: CGFloat = AppLayout.screenWidth / (Layout.headerSize.width + Layout.headerSpacing)
    static let headerSize: CGSize = CGSize(width: AppLayout.screenWidth * 0.66, height: 42.0)
}

final class MainAuthorizationsView: UIView {
    private let headerSwipingView = AuthorizationsHeadersSwipingView()
    private let authorizationSwipingView = AuthorizationsCollectionSwipingView()

    private lazy var translation: CGFloat = 0.0

    var dataSource: AuthorizationsDataSource?

    init() {
        super.init(frame: .zero)
        setupSwipingViews()
        setupPanGestures()
        layout()
    }

    func reloadData() {
        headerSwipingView.collectionView.reloadData()
        authorizationSwipingView.collectionView.reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            translation = recognizer.translation(in: self).x
        case .changed:
            if recognizer.view == authorizationSwipingView {
                let currentPosition = headerSwipingView.collectionView.contentOffset.x
                let finalTranslation = (recognizer.translation(in: self).x - translation) * Layout.headerMultiplier

                headerSwipingView.collectionView.setContentOffset(
                    CGPoint(x: currentPosition - finalTranslation, y: headerSwipingView.collectionView.contentOffset.y),
                    animated: false
                )
            } else {
                let currentPosition = authorizationSwipingView.collectionView.contentOffset.x
                let finalTranslation = (recognizer.translation(in: self).x - translation) * Layout.authorizationMultiplier

                authorizationSwipingView.collectionView.setContentOffset(
                    CGPoint(x: currentPosition - finalTranslation, y: authorizationSwipingView.collectionView.contentOffset.y),
                    animated: false
                )
            }
            translation = recognizer.translation(in: self).x
        default: break
        }
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let dataSource = self.dataSource, dataSource.rows > 1,
            let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            if let superview = self.superview {
                let translation = panGestureRecognizer.translation(in: superview)
                return abs(translation.x) > abs(translation.y)
            }
        }
        return false
    }
}

// MARK: - Setup
private extension MainAuthorizationsView {
    func setupPanGestures() {
        let headerPanGesture = UIPanGestureRecognizer()
        headerPanGesture.addTarget(self, action: #selector(handlePan))
        headerPanGesture.delegate = self
        headerSwipingView.addGestureRecognizer(headerPanGesture)

        let authorizationPanGesture = UIPanGestureRecognizer()
        authorizationPanGesture.addTarget(self, action: #selector(handlePan))
        authorizationPanGesture.delegate = self
        authorizationSwipingView.addGestureRecognizer(authorizationPanGesture)
    }

    func setupSwipingViews() {
        headerSwipingView.collectionView.dataSource = self
        headerSwipingView.collectionView.delegate = self
        authorizationSwipingView.collectionView.dataSource = self
        authorizationSwipingView.collectionView.delegate = self
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MainAuthorizationsView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UICollectionViewDataSource
extension MainAuthorizationsView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSource = self.dataSource else { return 0 }

        return dataSource.rows
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let dataSource = self.dataSource else { return 0 }

        return dataSource.sections
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = self.dataSource,
            let viewModel = dataSource.viewModel(at: indexPath.row) else { return UICollectionViewCell() }

        var cell: UICollectionViewCell

        if collectionView == headerSwipingView.collectionView {
            guard let headerCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "AuthorizationHeaderCollectionViewCell",
                for: indexPath
                ) as? AuthorizationHeaderCollectionViewCell else { return UICollectionViewCell() }

            headerCell.configure(viewModel, at: indexPath)
            cell = headerCell
        } else {
            guard let authorizationCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "AuthorizationCollectionViewCell",
                for: indexPath
                ) as? AuthorizationCollectionViewCell else { return UICollectionViewCell() }

            authorizationCell.set(with: viewModel)
            cell = authorizationCell
        }

        return cell
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let indexPath = authorizationSwipingView.collectionView.indexPathForItem(at: targetContentOffset.pointee)
            else { return }

        UIView.animate(withDuration: 0.2) {
            self.headerSwipingView.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension MainAuthorizationsView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == headerSwipingView.collectionView {
            headerSwipingView.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            authorizationSwipingView.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        guard collectionView == headerSwipingView.collectionView else { return .zero }

        let cellWidth: CGFloat = Layout.headerSize.width

        let numberOfCells = floor(frame.size.width / cellWidth)

        let edgeInsets = (frame.size.width - (numberOfCells * cellWidth)) / (numberOfCells + 1)

        return UIEdgeInsets(top: 0.0, left: edgeInsets, bottom: 0.0, right: edgeInsets)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == authorizationSwipingView.collectionView {
            return collectionView.size
        } else {
            return Layout.headerSize
        }
    }
}

// MARK: - Layout
extension MainAuthorizationsView: Layoutable {
    func layout() {
        addSubviews(headerSwipingView, authorizationSwipingView)

        headerSwipingView.topToSuperview()
        headerSwipingView.widthToSuperview()
        headerSwipingView.height(60.0)

        authorizationSwipingView.topToBottom(of: headerSwipingView)
        authorizationSwipingView.width(to: self)
        authorizationSwipingView.bottom(to: self, offset: -AppLayout.tabBarHeight)
    }
}
