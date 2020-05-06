//
//  AuthorizationsNoDataView
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

final class AuthorizationsNoDataView: NoDataView {
    enum AuthorizationsNoDataType {
        case noConnections
        case noAuthorizations
    }

    private var title: String
    private var descriptionText: String
    private var buttonTitle: String?

    var type: AuthorizationsNoDataType {
        didSet {
            guard type != oldValue else { return }

            if self.type == .noConnections {
                self.updateContent(
                    image: UIImage(),
                    title: l10n(.noConnections),
                    description: l10n(.noConnectionsDescription),
                    buttonTitle: l10n(.connect)
                )
            } else {
                self.updateContent(
                    image: UIImage(),
                    title: l10n(.noAuthorizations),
                    description: l10n(.noAuthorizationsDescription),
                    buttonTitle: nil
                )
            }
        }
    }

    init(type: AuthorizationsNoDataType, buttonAction: (() -> ())?) {
        if type == .noConnections {
            title = l10n(.noConnections)
            descriptionText = l10n(.noConnectionsDescription)
            buttonTitle = l10n(.connect)
        } else {
            title = l10n(.noAuthorizations)
            descriptionText = l10n(.noAuthorizationsDescription)
            buttonTitle = nil
        }
        self.type = type
        super.init(image: UIImage(), title: title, description: descriptionText, ctaTitle: buttonTitle, action: buttonAction)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
