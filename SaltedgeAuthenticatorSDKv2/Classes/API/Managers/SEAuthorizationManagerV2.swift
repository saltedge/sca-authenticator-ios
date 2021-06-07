//
//  SEAuthorizationManager
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

public struct SEAuthorizationManagerV2 {
    public static func getEncryptedAuthorizations(
        data: SEBaseAuthenticatedRequestData,
        onSuccess success: @escaping HTTPServiceSuccessClosure<SEEncryptedAuthorizationsListResponse>,
        onFailure failure: @escaping FailureBlock
    ) {
        HTTPService<SEEncryptedAuthorizationsListResponse>.execute(
            request: SEAuthorizationRouter.list(data),
            success: success,
            failure: failure
        )
    }

    public static func getEncryptedAuthorization(
        data: SEBaseAuthenticatedWithIdRequestData,
        onSuccess success: @escaping HTTPServiceSuccessClosure<SEEncryptedAuthorizationDataResponse>,
        onFailure failure: @escaping FailureBlock
    ) {
        HTTPService<SEEncryptedAuthorizationDataResponse>.execute(
            request: SEAuthorizationRouter.show(data),
            success: success,
            failure: failure
        )
    }

    public static func confirmAuthorization(
        url: URL,
        accessToken: AccessToken,
        data: SEAuthorizationRequestData,
        onSuccess success: @escaping HTTPServiceSuccessClosure<SEConfirmAuthorizationResponse>,
        onFailure failure: @escaping FailureBlock
    ) {
        HTTPService<SEConfirmAuthorizationResponse>.execute(
            request: SEAuthorizationRouter.confirm(url, accessToken, data),
            success: success,
            failure: failure
        )
    }

    public static func denyAuthorization(
        url: URL,
        accessToken: AccessToken,
        data: SEAuthorizationRequestData,
        onSuccess success: @escaping HTTPServiceSuccessClosure<SEConfirmAuthorizationResponse>,
        onFailure failure: @escaping FailureBlock
    ) {
        HTTPService<SEConfirmAuthorizationResponse>.execute(
            request: SEAuthorizationRouter.deny(url, accessToken, data),
            success: success,
            failure: failure
        )
    }
}

