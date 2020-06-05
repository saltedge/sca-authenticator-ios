//
//  FeaturesCollectionViewCell.swift
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
    static let imageViewTopOffset: CGFloat = 58.0
    static let imageViewSideOffset: CGFloat = 16.0
    static let imageViewHeight: CGFloat = AppLayout.screenHeight * 0.307

    static let titleLabelTopOffset: CGFloat = 78.0
    static let titleLabelSideOffset: CGFloat = 32.0

    static let descriptionLabelTopOffset: CGFloat = 20.0
    static let descriptionLabelSideOffset: CGFloat = 32.0
}

final class FeaturesCollectionViewCell: UICollectionViewCell {
    static var reuseIdentifier: String = "FeaturesCollectionViewCell"

    private let imageView = UIImageView(frame: .zero)
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let pageControl = UIPageControl()

    var viewModel: OnboardingCellViewModel! {
        didSet {
            imageView.image = viewModel.image
            titleLabel.text = viewModel.title
            descriptionLabel.text = viewModel.description
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .backgroundColor
        layout()
        stylize()
    }

    func set(image: UIImage, title: String, description: String) {
        imageView.image = image
        titleLabel.text = title
        descriptionLabel.text = description
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension FeaturesCollectionViewCell: Layoutable {
    func layout() {
        addSubviews(imageView, titleLabel, descriptionLabel)

        imageView.top(to: self, offset: Layout.imageViewTopOffset)
        imageView.left(to: self, offset: Layout.imageViewSideOffset)
        imageView.right(to: self, offset: -Layout.imageViewSideOffset)
        imageView.height(Layout.imageViewHeight)

        titleLabel.topToBottom(of: imageView, offset: Layout.titleLabelTopOffset)
        titleLabel.left(to: self, offset: Layout.titleLabelSideOffset)
        titleLabel.centerX(to: self)

        descriptionLabel.topToBottom(of: titleLabel, offset: Layout.descriptionLabelTopOffset)
        descriptionLabel.left(to: self, offset: Layout.descriptionLabelSideOffset)
        descriptionLabel.right(to: self, offset: -Layout.descriptionLabelSideOffset)
        descriptionLabel.centerX(to: self)
    }
}

// MARK: - Styleable
extension FeaturesCollectionViewCell: Styleable {
    func stylize() {
        titleLabel.font = .systemFont(ofSize: 26.0, weight: .semibold)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .titleColor

        descriptionLabel.font = .systemFont(ofSize: 17.0, weight: .regular)
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .titleColor

        imageView.contentMode = .scaleAspectFit
    }
}
