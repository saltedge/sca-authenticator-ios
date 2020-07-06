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

final class ConsentSharedDataView: UIView {
    private let sharedDataLabel: UILabel = {
        let label = UILabel(font: .auth_14regular)
        label.text = "Shared data"
        return label
    }()
    private let labelsStackView = UIStackView(axis: .horizontal, spacing: 10.0, distribution: .fill)
    private var dataArray = [String]()

    var data: SEConsentSharedData! {
        didSet {
            if data.balance != nil {
                dataArray.append("Balance")
            }
            if data.transactions != nil {
                dataArray.append("Transactions")
            }
            set(data: dataArray)
        }
    }

    init() {
        super.init(frame: .zero)
        layer.masksToBounds =  true
        layer.cornerRadius = 6.0
        backgroundColor = .extraLightGray
        layout()
    }

    private func set(data: [String]) {
        dataArray.forEach {
            let label = UILabel(font: .auth_14regular)
            label.backgroundColor = .secondaryBackground
            label.text = $0
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 12.0
            label.height(24.0)
            label.width(label.intrinsicContentSize.width + 20.0)
            labelsStackView.addArrangedSubview(label)
        }
    }

    func layout() {
        addSubviews(sharedDataLabel, labelsStackView)

        sharedDataLabel.leftToSuperview(offset: 16.0)
        sharedDataLabel.centerYToSuperview()

        labelsStackView.rightToSuperview(offset: -16.0)
        labelsStackView.centerYToSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
