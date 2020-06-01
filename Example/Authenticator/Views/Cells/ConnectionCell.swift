//
//  ConnectionCell.swift
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

private struct Layout {
    static let sideOffset: CGFloat = 16.0
    static let titleLabelTopOffset: CGFloat = 20.0
    static let descriptionLabelOffset: CGFloat = 4.0
    static let imageViewSize: CGSize = CGSize(width: 36.0, height: 36.0)
    static let connectionPlaceholderViewSize: CGSize = CGSize(width: 48.0, height: 48.0)
    static let connectionPlaceholderViewRadius: CGFloat = 12.0
    static let connectionImageOffset = sideOffset + 4.0
    static let cardViewRadius: CGFloat = 6.0
    static let cardViewLeftRightOffset: CGFloat = 16.0
    static let cardViewTopBottomOffset: CGFloat = 8.0
}

final class ConnectionCell: UITableViewCell, Dequeuable {
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Layout.cardViewRadius
        view.layer.masksToBounds = true
        view.backgroundColor = .secondaryBackground
        return view
    }()
    private let logoPlaceholderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Layout.connectionPlaceholderViewRadius
        view.clipsToBounds = true
        view.backgroundColor = .extraLightGray
        return view
    }()
    private let logoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .auth_17regular
        label.textColor = .titleColor
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .auth_13regular
        label.textColor = .dark60
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    var viewModel: ConnectionCellViewModel! {
        didSet {
            titleLabel.text = viewModel.connectionName
            descriptionLabel.text = viewModel.description
            descriptionLabel.textColor = viewModel.descriptionColor

            if let imageUrl = viewModel.logoUrl {
                CacheHelper.setAnimatedCachedImage(from: imageUrl, for: logoImageView)
            }
        }
    }

    var picked: Bool = false {
        didSet {
            if picked {
                cardView.layer.borderWidth = 2.0
                cardView.layer.borderColor = UIColor.lightBlue.cgColor
            } else {
                cardView.layer.borderWidth = 0.0
                cardView.layer.borderColor = nil
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupContentContainer()
        layout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension ConnectionCell {
    func setupContentContainer() {
        backgroundColor = .backgroundColor

        contentView.layer.borderWidth = 2.0
        contentView.layer.shadowColor = UIColor(red: 0.374, green: 0.426, blue: 0.488, alpha: 0.3).cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = Layout.cardViewTopBottomOffset
    }
}

// MARK: - Layout
extension ConnectionCell: Layoutable {
    func layout() {
        contentView.addSubviews(cardView)
        cardView.addSubviews(logoPlaceholderView, titleLabel, descriptionLabel)
        logoPlaceholderView.addSubview(logoImageView)

        cardView.left(to: contentView, offset: Layout.cardViewLeftRightOffset)
        cardView.top(to: contentView, offset: Layout.cardViewTopBottomOffset)
        cardView.right(to: contentView, offset: -Layout.cardViewLeftRightOffset)
        cardView.bottom(to: contentView, offset: -Layout.cardViewTopBottomOffset)

        logoPlaceholderView.size(Layout.connectionPlaceholderViewSize)
        logoPlaceholderView.left(to: cardView, offset: Layout.sideOffset)
        logoPlaceholderView.centerY(to: cardView)

        logoImageView.size(Layout.connectionPlaceholderViewSize)
        logoImageView.center(in: logoPlaceholderView)

        titleLabel.top(to: cardView, offset: Layout.titleLabelTopOffset)
        titleLabel.leftToRight(of: logoPlaceholderView, offset: Layout.sideOffset)
        titleLabel.right(to: cardView, offset: -Layout.sideOffset)

        descriptionLabel.topToBottom(of: titleLabel, offset: Layout.descriptionLabelOffset)
        descriptionLabel.leftToRight(of: logoPlaceholderView, offset: Layout.sideOffset)
        descriptionLabel.right(to: cardView, offset: -Layout.descriptionLabelOffset)
    }
}
