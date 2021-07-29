//
//  SEConsentManagerV2
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2021 Salt Edge Inc.
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
import SEAuthenticatorCore

public struct SEConsentManagerV2 {
    public static func getEncryptedConsents(
        data: SEBaseAuthenticatedRequestData,
        onSuccess success: @escaping HTTPServiceSuccessClosure<SEEncryptedListResponse>,
        onFailure failure: @escaping FailureBlock
    ) {
        HTTPService<SEEncryptedListResponse>.execute(
            request: SEConsentRouter.list(data),
            success: success,
            failure: failure
        )
    }
    
    public static func revokeConsent(
        data: SEBaseAuthenticatedWithIdRequestData,
        onSuccess success: @escaping HTTPServiceSuccessClosure<SERevokeConsentResponseV2>,
        onFailure failure: @escaping FailureBlock
    ) {
        let parameters = RequestParametersBuilder.expirationTimeParameters

        HTTPService<SERevokeConsentResponseV2>.execute(
            request: SEConsentRouter.revoke(data, parameters),
            success: success,
            failure: failure
        )
    }
}
