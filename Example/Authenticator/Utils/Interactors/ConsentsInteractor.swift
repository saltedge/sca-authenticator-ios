//
//  ConsentsInteractor.swift
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

struct ConsentsInteractor {
    
    static func refresh(
        connections: [Connection],
        success: @escaping ([SEEncryptedData]) -> (),
        failure: ((String) -> ())? = nil,
        connectionNotFoundFailure: @escaping ((String?) -> ())
    ) {
        var encryptedConsents = [SEEncryptedData]()

        var numberOfResponses = 0

        func incrementAndCheckResponseCount() {
            numberOfResponses += 1

            if numberOfResponses == connections.count {
                success(encryptedConsents)
            }
        }

        for connection in connections {
            let accessToken = connection.accessToken

            guard let baseUrl = connection.baseUrl else { failure?(l10n(.somethingWentWrong)); return }

            SEConsentsManager.getEncryptedConsents(
                data: SEBaseAuthenticatedRequestData(
                    url: baseUrl,
                    connectionGuid: connection.guid,
                    accessToken: accessToken,
                    appLanguage: UserDefaultsHelper.applicationLanguage
                ),
                onSuccess: { response in
                    encryptedConsents.append(contentsOf: response.data)

                    incrementAndCheckResponseCount()
                },
                onFailure: { error in
                    incrementAndCheckResponseCount()

                    if SEAPIError.connectionNotFound.isConnectionNotFound(error) {
                        connectionNotFoundFailure(connection.id)
                    } else {
                        failure?("\(l10n(.somethingWentWrong)) (\(connection.name))")
                    }
                }
            )
        }
    }
}
