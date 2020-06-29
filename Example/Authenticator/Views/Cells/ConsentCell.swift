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
}

final class ConsentCell: UITableViewCell {
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

    init() {
        super.init(style: .default, reuseIdentifier: nil)
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension ConsentCell: Layoutable {
    func layout() {
        contentView.addSubview(cardView)

        cardView.addSubviews(titleLabel, descriptionLabel, expirationLabel)
    }
}
