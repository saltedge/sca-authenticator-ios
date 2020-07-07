//
//  ConsentSharedDataView
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
import SEAuthenticator

private struct Layout {
    static let labelsSpacing: CGFloat = 10.0
    static let viewCornerRadius: CGFloat = 6.0
    static let labelCornerRadius: CGFloat = 12.0
    static let labelHeight: CGFloat = 24.0
    static let sideOffset: CGFloat = 16.0
    static let sharedDataLabelRightOffset: CGFloat = -5.0
}

final class ConsentSharedDataView: UIView {
    private let sharedDataLabel: UILabel = {
        let label = UILabel()
        label.font = .auth_14regular
        label.text = "\(l10n(.sharedData)):"
        return label
    }()
    private let labelsStackView = UIStackView(axis: .horizontal, spacing: Layout.labelsSpacing, distribution: .fill)
    private var dataArray = [String]()

    var data: SEConsentSharedData! {
        didSet {
            if data.balance != nil {
                dataArray.append(l10n(.balance))
            }
            if data.transactions != nil {
                dataArray.append(l10n(.transactions))
            }
            set(data: dataArray)
        }
    }

    init() {
        super.init(frame: .zero)
        layer.masksToBounds =  true
        layer.cornerRadius = Layout.viewCornerRadius
        backgroundColor = .extraLightGray_blueBlack
        layout()
    }

    private func set(data: [String]) {
        dataArray.forEach {
            let label = UILabel(font: .auth_14regular, textColor: .dark80_grey100)
            label.backgroundColor = .white_dark100
            label.text = $0
            label.layer.masksToBounds = true
            label.layer.cornerRadius = Layout.labelCornerRadius
            label.height(Layout.labelHeight)
            label.width(label.intrinsicContentSize.width + 20.0)
            labelsStackView.addArrangedSubview(label)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layoutable
extension ConsentSharedDataView: Layoutable {
    func layout() {
        addSubviews(sharedDataLabel, labelsStackView)

        sharedDataLabel.leftToSuperview(offset: Layout.sideOffset)
        sharedDataLabel.centerYToSuperview()
        sharedDataLabel.rightToLeft(of: labelsStackView, offset: Layout.sharedDataLabelRightOffset, relation: .equalOrLess)

        labelsStackView.rightToSuperview(offset: -Layout.sideOffset, relation: .equalOrLess)
        labelsStackView.centerYToSuperview()
    }
}
