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
    static let labelsSpacing: CGFloat = 4.0
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
            let titleLabel = label(text: accountData.name, font: .auth_16semibold)
            titleLabel.height(Layout.titleLabelHeight)
            labelsStackView.addArrangedSubview(titleLabel)

            if let accountNumber = accountData.accountNumber {
                let accountNumberLabel = label(text: "\(l10n(.accountNumber)): \(accountNumber)", font: .auth_14regular)
                accountNumberLabel.height(Layout.informationLabelsHeight)
                labelsStackView.addArrangedSubview(accountNumberLabel)
            }
            if let sortCode = accountData.sortCode {
                let sortCodeLabel = label(text: "\(l10n(.sortCode)): \(sortCode)", font: .auth_14regular)
                sortCodeLabel.height(Layout.informationLabelsHeight)
                labelsStackView.addArrangedSubview(sortCodeLabel)
            }
            if let iban = accountData.iban {
                let ibanLabel = label(text: "\(l10n(.sortCode)): \(iban)", font: .auth_14regular)
                ibanLabel.height(Layout.informationLabelsHeight)
                labelsStackView.addArrangedSubview(ibanLabel)
            }
        }
    }

    init() {
        super.init(frame: .zero)
        backgroundColor = .extraLightGray
        layout()
    }

    private func label(text: String, font: UIFont) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textAlignment = .left
        label.text = text
        return label
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
