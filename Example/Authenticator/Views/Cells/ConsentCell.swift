//
//  ConsentCell
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
    static let cardViewRadius: CGFloat = 6.0
    static let cardViewLeftRightOffset: CGFloat = 16.0
    static let cardViewTopBottomOffset: CGFloat = 8.0
    static let labelsSideOffset: CGFloat = 16.0
    static let titleTopOffset: CGFloat = 12.0
    static let descriptionLabelTopOffset: CGFloat = 2.0
    static let expirationLabelTopOffset: CGFloat = 2.0
    static let disclosureIndicatorRightOffset: CGFloat = -16.0
    static let disclosureIndicatorSize: CGSize = CGSize(width: 7.0, height: 11.0)
}

struct ConsentCellViewModel {
    let title: String
    let description: String
    let expiration: NSMutableAttributedString
}

final class ConsentCell: UITableViewCell, Dequeuable {
    let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Layout.cardViewRadius
        view.layer.masksToBounds = true
        view.backgroundColor = .secondaryBackground
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
    private let expirationLabel: UILabel = {
        let label = UILabel()
        label.font = .auth_13regular
        label.textColor = .dark60
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    private let disclosureIndicatorImageView = AspectFitImageView(imageName: "disclosureIndicator")

    var viewModel: ConsentCellViewModel! {
        didSet {
            titleLabel.text = viewModel.title
            descriptionLabel.text = viewModel.description
            expirationLabel.attributedText = viewModel.expiration
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupShadowAndRadius()
        layout()
    }

    private func setupShadowAndRadius() {
        contentView.layer.shadowColor = UIColor(red: 0.374, green: 0.426, blue: 0.488, alpha: 0.3).cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 6)
        contentView.layer.shadowOpacity = 0.8
        contentView.layer.shadowRadius = Layout.cardViewTopBottomOffset
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension ConsentCell: Layoutable {
    func layout() {
        contentView.addSubview(cardView)

        cardView.addSubviews(titleLabel, descriptionLabel, expirationLabel, disclosureIndicatorImageView)

        cardView.left(to: contentView, offset: Layout.cardViewLeftRightOffset)
        cardView.top(to: contentView, offset: Layout.cardViewTopBottomOffset)
        cardView.right(to: contentView, offset: -Layout.cardViewLeftRightOffset)
        cardView.bottom(to: contentView, offset: -Layout.cardViewTopBottomOffset)

        titleLabel.topToSuperview(offset: Layout.titleTopOffset)
        titleLabel.leftToSuperview(offset: Layout.labelsSideOffset)

        descriptionLabel.topToBottom(of: titleLabel, offset: Layout.descriptionLabelTopOffset)
        descriptionLabel.leftToSuperview(offset: Layout.labelsSideOffset)

        expirationLabel.topToBottom(of: descriptionLabel, offset: Layout.expirationLabelTopOffset)
        expirationLabel.leftToSuperview(offset: Layout.labelsSideOffset)

        disclosureIndicatorImageView.centerYToSuperview()
        disclosureIndicatorImageView.rightToSuperview(offset: Layout.disclosureIndicatorRightOffset)
        disclosureIndicatorImageView.size(Layout.disclosureIndicatorSize)
    }
}
