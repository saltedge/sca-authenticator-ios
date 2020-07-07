//
//  ConsentAccountView
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

struct ConsentAccountViewData {
    let name: String
    let accountNumber: String?
    let sortCode: String?
    let iban: String?
}

private struct Layout {
    static let labelsSpacing: CGFloat = 6.0
    static let stackViewTopOffset: CGFloat = 16.0
    static let stackViewLeftOffset: CGFloat = 16.0
    static let stackViewBottomOffset: CGFloat = -16.0
    static let titleLabelHeight: CGFloat = 16.0
    static let informationLabelsHeight: CGFloat = 14.0
}

final class ConsentAccountView: UIView {
    private let labelsStackView = UIStackView(axis: .vertical, spacing: Layout.labelsSpacing, distribution: .fillProportionally)

    var accountData: ConsentAccountViewData! {
        didSet {
            addLabelToStackView(title: accountData.name, font: .auth_16semibold, height: Layout.titleLabelHeight)

            if let accountNumber = accountData.accountNumber {
                addLabelToStackView(
                    title: l10n(.accountNumber),
                    description: accountNumber,
                    font: .auth_14regular,
                    height: Layout.informationLabelsHeight
                )
            }
            if let sortCode = accountData.sortCode {
                addLabelToStackView(
                    title: l10n(.sortCode),
                    description: sortCode,
                    font: .auth_14regular,
                    height: Layout.informationLabelsHeight
                )
            }
            if let iban = accountData.iban {
                addLabelToStackView(
                    title: l10n(.iban),
                    description: iban,
                    font: .auth_14regular,
                    height: Layout.informationLabelsHeight
                )
            }
        }
    }

    init() {
        super.init(frame: .zero)
        backgroundColor = .extraLightGray_blueBlack
        layout()
    }

    private func addLabelToStackView(title: String, description: String? = nil, font: UIFont, height: CGFloat) {
        let label = UILabel(font: font, alignment: .left)
        label.height(height)

        if let description = description {
            let attributedText = NSMutableAttributedString(string: "\(title): ")
            let attributedDescription = NSMutableAttributedString(
                string: description,
                attributes: [NSAttributedString.Key.font: UIFont.auth_14semibold]
            )
            attributedText.append(attributedDescription)
            label.attributedText = attributedText
        } else {
            label.text = title
        }

        labelsStackView.addArrangedSubview(label)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension ConsentAccountView: Layoutable {
    func layout() {
        addSubview(labelsStackView)

        labelsStackView.topToSuperview(offset: Layout.stackViewTopOffset)
        labelsStackView.leftToSuperview(offset: Layout.stackViewLeftOffset)
        labelsStackView.bottomToSuperview(offset: Layout.stackViewBottomOffset)
    }
}
