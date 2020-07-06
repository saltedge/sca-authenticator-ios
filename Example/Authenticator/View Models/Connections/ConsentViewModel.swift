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

enum ConsentType: String {
    case aisp
    case pispFuture = "pisp_future"
    case pispRecurring = "pisp_recurring"

    var description: String {
        switch self {
        case .aisp: return l10n(.aispDescription)
        case .pispFuture: return l10n(.pispFutureDescription)
        case .pispRecurring: return l10n(.pispRecurringDescription)
        }
    }
}

protocol ConsentsEventsDelegate: class {
    func reloadData()
}

final class ConsentsViewModel {
    private let connection: Connection!
    private var consents: [SEConsentData]

    weak var delegate: ConsentsEventsDelegate?

    init(connectionId: ID, consents: [SEConsentData]) {
        self.connection = ConnectionsCollector.with(id: connectionId)
        self.consents = consents
    }

    var consentsCount: Int {
        return consents.count
    }

    var logoViewData: ConsentLogoViewData {
        let expiresString = consents.count > 1 ? l10n(.consents) : l10n(.consent)

        return ConsentLogoViewData(
            imageUrl: connection.logoUrl,
            title: connection.name,
            description: "\(consents.count) \(expiresString)"
        )
    }

    func cellViewModel(for indexPath: IndexPath) -> ConsentCellViewModel {
        let consent = consents[indexPath.row]

        let expirationAttributedString = NSMutableAttributedString()

        let numberOfDaysToExpire = consent.expiresAt.get(.day)
        let expiresInString = numberOfDaysToExpire == 1 ? "\(numberOfDaysToExpire) \(l10n(.day))"
            : "\(numberOfDaysToExpire) \(l10n(.days))"
        let expiresInAttributedMessage = NSMutableAttributedString(
            string: expiresInString,
            attributes: [
                NSAttributedString.Key.foregroundColor: numberOfDaysToExpire < 10 ? UIColor.redAlert : UIColor.titleColor,
                NSAttributedString.Key.font: UIFont.auth_13semibold
            ]
        )
        expirationAttributedString.append(NSMutableAttributedString(string: "\(l10n(.expiresIn)) "))
        expirationAttributedString.append(expiresInAttributedMessage)

        return ConsentCellViewModel(
            title: consent.tppName,
            description: ConsentType(rawValue: consent.consentType)?.description ?? "",
            expiration: expirationAttributedString
        )
    }

    func consent(for indexPath: IndexPath) -> SEConsentData {
        return consents[indexPath.row]
    }

    func updateConsents(with consents: [SEConsentData]) {
        self.consents = consents
        delegate?.reloadData()
    }

    func refreshConsents(completion: (() -> ())? = nil) {
        CollectionsInteractor.consents.refresh(
            connection: connection,
            success: { [weak self] encryptedConsents in
                guard let strongSelf = self else { return }

                DispatchQueue.global(qos: .background).async {
                    let decryptedConsents = encryptedConsents.compactMap { $0.decryptedConsentData }

                    DispatchQueue.main.async {
                        strongSelf.updateConsents(with: decryptedConsents)
                        completion?()
                    }
                }
            },
            failure: { error in
                completion?()
                print(error)
            },
            connectionNotFoundFailure: { connectionId in
                if let id = connectionId, let connection = ConnectionsCollector.with(id: id) {
                    ConnectionRepository.setInactive(connection)
                    completion?()
                }
            }
        )
    }
}
