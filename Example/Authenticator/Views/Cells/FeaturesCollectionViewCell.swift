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
    static let topImageViewOffset: CGFloat = 106.0
    static let imageViewSize: CGSize = CGSize(width: 180.0, height: 180.0)
    static let titleLabelTopOffset: CGFloat = 30.0
    static let descriptionLabelTopOffset: CGFloat = 17.0
}

final class FeaturesCollectionViewCell: UICollectionViewCell {
    static var reuseIdentifier: String = "FeaturesCollectionViewCell"

    private let containerView = UIView()
    private let imageView = UIImageView(frame: .zero)
    private let titleLabel = UILabel.titleLabel
    private let descriptionLabel = UILabel.descriptionLabel

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
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
        addSubview(containerView)

        containerView.addSubviews(imageView, titleLabel, descriptionLabel)

        containerView.height(388.0)
        containerView.center(in: contentView)
        containerView.left(to: contentView, offset: AppLayout.sideOffset)
        containerView.right(to: contentView, offset: -AppLayout.sideOffset)

        imageView.top(to: containerView)
        imageView.centerX(to: containerView)
        imageView.size(Layout.imageViewSize)

        titleLabel.topToBottom(of: imageView, offset: Layout.titleLabelTopOffset)
        titleLabel.centerX(to: containerView)

        descriptionLabel.topToBottom(of: titleLabel, offset: Layout.descriptionLabelTopOffset)
        descriptionLabel.centerX(to: contentView)
        descriptionLabel.left(to: containerView)
        descriptionLabel.right(to: containerView)
    }
}

// MARK: - Styleable
extension FeaturesCollectionViewCell: Styleable {
    func stylize() {
        imageView.contentMode = .scaleAspectFit
    }
}
