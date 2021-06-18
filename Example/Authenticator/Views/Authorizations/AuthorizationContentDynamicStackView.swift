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
import SEAuthenticatorCore

private enum FieldType: String {
    case payment
    case extra
    case text

    var textColor: UIColor {
        switch self {
        case .payment: return .dark80_grey100
        case .extra: return .extraTextColor
        case .text: return .titleColor
        }
    }
}

/*
    The UIStackView which is designed to construct the authorization content dynamically.
 */
final class AuthorizationContentDynamicStackView: UIStackView {
    private let paymentSortedKeys = [
        SENetKeys.payee, SENetKeys.amount, SENetKeys.account,
        SENetKeys.paymentDate, SENetKeys.reference, SENetKeys.fee, SENetKeys.exchangeRate
    ]
    private let extraSortedKeys = [SENetKeys.actionDate, SENetKeys.device, SENetKeys.location, SENetKeys.ip]

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

        if let paymentDict = attributes[SENetKeys.payment] as? [String: Any] {
            paymentSortedKeys.forEach {
                addArrangedSubview(inputDict: paymentDict, key: $0, type: .payment)
            }
        }
        if let text = attributes[SENetKeys.text] as? String {
            let label = UILabel(
                font: .systemFont(ofSize: 16.0, weight: .regular),
                alignment: .left,
                textColor: FieldType.text.textColor
            )
            label.text = text
            addArrangedSubview(label)
        }
        if let extraDict = attributes[SENetKeys.extra] as? [String: Any] {
            // Adding empty view as separator between blocks
            let emptyView = UIView()
            emptyView.height(16.0)
            addArrangedSubview(emptyView)

            extraSortedKeys.forEach {
                addArrangedSubview(inputDict: extraDict, key: $0, type: .extra)
            }
        }
    }

    private func addArrangedSubview(inputDict: [String: Any]?, key: String, type: FieldType) {
        if let value = inputDict?[key] as? String, !value.isEmpty {
            addArrangedSubview(contentView(title: key, description: value, fieldType: type))
        }
    }

    private func contentView(title: String? = nil, description: String, fieldType: FieldType) -> UIView {
        let contentView = UIView()
        let contentTitleLabel = UILabel(
            font: .systemFont(ofSize: 16.0, weight: .regular),
            textColor: fieldType.textColor
        )
        let descriptionLabel = UILabel(
            font: .systemFont(ofSize: 16.0, weight: .regular),
            alignment: .right,
            textColor: fieldType == .payment ? .titleColor : FieldType.extra.textColor
        )

        var title = title?.replacingOccurrences(of: "_", with: " ").capitalizingFirstLetter() ?? ""

        if fieldType == .extra {
            if title == SENetKeys.ip.capitalizingFirstLetter() {
                title = l10n(.ipAddress)
            }

            title += ":"
        }

        contentTitleLabel.text = title
        descriptionLabel.text = description

        contentView.addSubviews(contentTitleLabel, descriptionLabel)

        contentTitleLabel.leftToSuperview()
        contentTitleLabel.centerYToSuperview()
        descriptionLabel.centerYToSuperview()

        if fieldType == .payment {
            descriptionLabel.leftToRight(of: contentTitleLabel, offset: 16.0, relation: .equalOrGreater)
            descriptionLabel.rightToSuperview(offset: -16.0)
        } else {
            descriptionLabel.leftToRight(of: contentTitleLabel, offset: 6.0)
        }
        contentView.height(fieldType == .payment ? 24.0 : 18.0)

        return contentView
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
