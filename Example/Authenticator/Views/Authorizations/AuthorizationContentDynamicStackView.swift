//
//  AuthorizationContentDynamicStackView
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2021 Salt Edge Inc.
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

private enum FieldType: String {
    case payment
    case extra
}

/*
    The UIStackView which is designed to construct the authorization content dynamically.
 */
final class AuthorizationContentDynamicStackView: UIStackView {
    init() {
        super.init(frame: .zero)
        axis = .vertical
        alignment = .fill
        distribution = .fillProportionally
        spacing = 8.0
    }

    /*
     Setup the stackView content using the authorization description attributes.

     The content will be constructed using next attributes:
        - payment
        - text
        - extra

      - parameters:
        - attributes: Authorization description dictionary with nested attributes dictionaries
     */
    func setup(using attributes: [String: Any]) {
        removeAllArrangedSubviews()

        if let paymentDict = attributes["payment"] as? [String: String] {
            for (key, value) in paymentDict {
                addArrangedSubview(contentView(title: key, description: value, fieldType: .payment))
            }
        }
        if let text = attributes["text"] as? String {
            let label = UILabel(
                font: .systemFont(ofSize: 16.0, weight: .regular),
                alignment: .left,
                textColor: .titleColor
            )
            label.text = text
            addArrangedSubview(label)
        }
        if let extraDict = attributes["extra"] as? [String: String] {
            for (key, value) in extraDict {
                addArrangedSubview(contentView(title: key, description: value, fieldType: .extra))
            }
        }
    }

    private func contentView(title: String? = nil, description: String, fieldType: FieldType) -> UIView {
        let contentView = UIView()
        let contentTitleLabel = UILabel(
            font: .systemFont(ofSize: 16.0, weight: .regular),
            textColor: fieldType == .extra ? .dark60 : .titleColor
        )
        let descriptionLabel = UILabel(
            font: .systemFont(ofSize: 16.0, weight: .regular),
            textColor: fieldType == .extra ? .dark60 : .titleColor
        )

        var title = title?.replacingOccurrences(of: "_", with: " ").capitalizingFirstLetter() ?? ""

        if fieldType == .extra {
            title = "\(title):"
        }

        contentTitleLabel.text = title
        descriptionLabel.text = description

        contentView.addSubviews(contentTitleLabel, descriptionLabel)

        contentTitleLabel.leftToSuperview()
        contentTitleLabel.centerYToSuperview()
        descriptionLabel.centerYToSuperview()

        if fieldType == .payment {
            descriptionLabel.leftToRight(of: contentTitleLabel, offset: 32.0, relation: .equalOrGreater)
            descriptionLabel.rightToSuperview(offset: -16.0)
        } else {
            descriptionLabel.leftToRight(of: contentTitleLabel, offset: 6.0)
        }
        contentView.height(18.0)

        return contentView
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
