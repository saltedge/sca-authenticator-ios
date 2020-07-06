//
//  ConsentDetailViewModel
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

protocol ConsentDetailViewModelEventsDelegate: class {
    func revoke(_ consent: SEConsentData)
}

final class ConsentDetailViewModel {
    private var consent: SEConsentData
    private var connectionName: String
    var navigationTitle: String

    weak var delegate: ConsentDetailViewModelEventsDelegate?

    init(connectionName: String, consent: SEConsentData) {
        self.consent = consent
        self.connectionName = connectionName
        self.navigationTitle = consent.tppName
    }

    var title: String {
        return ConsentType(rawValue: consent.consentType)?.description ?? ""
    }

    var expiresInText: String {
        return "\(consent.expiresAt.get(.day)) \(l10n(.daysLeft))"
    }

    var descriptionAtributedString: NSMutableAttributedString {
        let attributedDescription = NSMutableAttributedString(string: l10n(.consentGrantedTo))

        let fontAttribute = [
            NSAttributedString.Key.font: UIFont.auth_14semibold
        ]

        guard let consentLocation = attributedDescription.string.range(of: "%{consent}")
            else { return NSMutableAttributedString(string: "") }

        let consentRange = NSRange(consentLocation, in: attributedDescription.string)

        let tppAttributedName = NSMutableAttributedString(
            string: consent.tppName.capitalized,
            attributes: fontAttribute
        )
        attributedDescription.replaceCharacters(in: consentRange, with: tppAttributedName)

        guard let connectionLocation = attributedDescription.string.range(of: "%{connection}")
            else { return NSMutableAttributedString(string: "") }

        let connectionRange = NSRange(connectionLocation, in: attributedDescription.string)

        let connectionAttributedName = NSMutableAttributedString(
            string: connectionName.capitalized,
            attributes: fontAttribute
        )

        attributedDescription.replaceCharacters(in: connectionRange, with: connectionAttributedName)

        return attributedDescription
    }

    var accountsViewDataArray: [ConsentAccountViewData] {
        return consent.accounts.map {
            ConsentAccountViewData(name: $0.name, accountNumber: $0.accountNumber, sortCode: $0.sortCode, iban: $0.iban)
        }
    }

    var consentSharedData: SEConsentSharedData? {
        return consent.sharedData
    }

    var hasSharedData: Bool {
        return consent.sharedData != nil
    }

    var expirationData: ConsentExpirationData {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.timeZone = .utc

        return ConsentExpirationData(
            granted: formatter.string(from: consent.createdAt),
            expires: formatter.string(from: consent.expiresAt)
        )
    }
}

// MARK: - Actions
extension ConsentDetailViewModel {
    func revokePressed() {
        delegate?.revoke(consent)
    }
}
