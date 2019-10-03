//
//  ConnectionCell.swift
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
    static let sideOffset: CGFloat = 16.0
    static let titleLabelTopOffset: CGFloat = 20.0
    static let descriptionLabelTopOffset: CGFloat = 5.0
    static let imageViewSize: CGSize = CGSize(width: 30.0, height: 30.0)
    static let connectionPlaceholderViewSize: CGSize = CGSize(width: 48.0, height: 48.0)
    static let connectionPlaceholderViewRadius: CGFloat = 24.0
    static let connectionImageOffset = sideOffset + 4.0
}

final class ConnectionCell: UITableViewCell, Dequeuable {
    private let connectionPlaceholderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Layout.connectionPlaceholderViewRadius
        view.clipsToBounds = true
        view.backgroundColor = .auth_backgroundColor
        return view
    }()
    private let connectionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .auth_19regular
        label.textColor = .black
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .auth_15regular
        label.textColor = .darkGray
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        layout()
    }

    func set(bankName: String, description: String, descriptionColor: UIColor = .auth_gray, imageUrl: URL?) {
        titleLabel.text = bankName
        descriptionLabel.text = description
        descriptionLabel.textColor = descriptionColor

        guard let imageUrl = imageUrl else { return }

        ConnectionImageHelper.setAnimatedCachedImage(from: imageUrl, for: connectionImageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension ConnectionCell: Layoutable {
    func layout() {
        contentView.addSubviews(connectionPlaceholderView, titleLabel, descriptionLabel)

        connectionPlaceholderView.addSubview(connectionImageView)

        connectionPlaceholderView.size(Layout.connectionPlaceholderViewSize)
        connectionPlaceholderView.left(to: contentView, offset: Layout.sideOffset)
        connectionPlaceholderView.centerY(to: contentView)

        connectionImageView.size(Layout.connectionPlaceholderViewSize)
        connectionImageView.center(in: connectionPlaceholderView)

        titleLabel.top(to: contentView, offset: Layout.titleLabelTopOffset)
        titleLabel.leftToRight(of: connectionPlaceholderView, offset: Layout.sideOffset)
        titleLabel.right(to: contentView, offset: -Layout.sideOffset)

        descriptionLabel.topToBottom(of: titleLabel, offset: Layout.descriptionLabelTopOffset)
        descriptionLabel.leftToRight(of: connectionPlaceholderView, offset: Layout.sideOffset)
    }
}
