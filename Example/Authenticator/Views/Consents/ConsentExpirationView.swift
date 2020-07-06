//
//  ConsentExpirationView
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

struct ConsentExpirationData {
    let granted: String
    let expires: String
}

private struct Layout {
    static let expiresLabelTopOffset: CGFloat = 8.0
}

final class ConsentExpirationView: UIView {
    private let grantedLabel = UILabel(font: .auth_14regular)
    private let expiresLabel = UILabel(font: .auth_14regular)

    var data: ConsentExpirationData! {
        didSet {
            grantedLabel.text = "\(l10n(.granted)): \(data.granted)"
            expiresLabel.text = "\(l10n(.expires)): \(data.expires)"
        }
    }

    init() {
        super.init(frame: .zero)
        layout()
    }

    func layout() {
        addSubviews(grantedLabel, expiresLabel)

        grantedLabel.topToSuperview()
        grantedLabel.leftToSuperview()

        expiresLabel.topToBottom(of: grantedLabel, offset: Layout.expiresLabelTopOffset)
        expiresLabel.leftToSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
