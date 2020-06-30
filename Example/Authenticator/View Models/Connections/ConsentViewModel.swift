//
//  ConsentViewModel
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

import Foundation
import SEAuthenticator

final class ConsentsViewModel {
    private let connection: Connection!
    private let consents: [SEConsentData]

    init(connectionId: ID, consents: [SEConsentData]) {
        self.connection = ConnectionsCollector.with(id: connectionId)
        self.consents = consents
    }

    var consentsCount: Int {
        return consents.count
    }

    var logoViewData: ConsentLogoViewData {
        let expiresString = consents.count > 1 ? "consents" : "consent"
        return ConsentLogoViewData(
            imageUrl: connection.logoUrl,
            title: connection.name,
            description: "\(consents.count) \(expiresString)"
        )
    }

    func cellViewModel(for indexPath: IndexPath) -> ConsentCellViewModel {
        let consent = consents[indexPath.row]

        return ConsentCellViewModel(
            title: consent.tppName,
            description: consent.consentType,
            expiration: "Expires in \(consent.expiresAt.get(.day)) day"
        )
    }
}
