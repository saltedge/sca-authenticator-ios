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
        onSuccess success: SEHTTPResponse<SEEncryptedAuthorizationsListResponse>,
        onFailure failure: @escaping FailureBlock
    ) {
        HTTPService<SEEncryptedAuthorizationsListResponse>.makeRequest(
            SEAuthorizationRouter.list(data),
            completion: success,
            failure: failure
        )
    }

    public static func getEncryptedAuthorization(
        data: SEBaseAuthenticatedWithIdRequestData,
        onSuccess success: SEHTTPResponse<SEEncryptedAuthorizationDataResponse>,
        onFailure failure: @escaping FailureBlock
    ) {
        HTTPService<SEEncryptedAuthorizationDataResponse>.makeRequest(
            SEAuthorizationRouter.show(data),
            completion: success,
            failure: failure
        )
    }

    public static func confirmAuthorization(
        data: SEConfirmAuthorizationRequestData,
        onSuccess success: SEHTTPResponse<SEConfirmAuthorizationResponseV2>,
        onFailure failure: @escaping FailureBlock
    ) {
        let parameters = RequestParametersBuilder.confirmAuthorizationParams(
            encryptedData: encryptedData(requestData: data),
            exp: Date().addingTimeInterval(5.0 * 60.0).utcSeconds
        )

        HTTPService<SEConfirmAuthorizationResponseV2>.makeRequest(
            SEAuthorizationRouter.confirm(data, parameters),
            completion: success,
            failure: failure
        )
    }

    public static func denyAuthorization(
        data: SEConfirmAuthorizationRequestData,
        onSuccess success: SEHTTPResponse<SEConfirmAuthorizationResponseV2>,
        onFailure failure: @escaping FailureBlock
    ) {
        let parameters = RequestParametersBuilder.confirmAuthorizationParams(
            encryptedData: encryptedData(requestData: data),
            exp: Date().addingTimeInterval(5.0 * 60.0).utcSeconds
        )

        HTTPService<SEConfirmAuthorizationResponseV2>.makeRequest(
            SEAuthorizationRouter.deny(data, parameters),
            completion: success,
            failure: failure
        )
    }

    // Encrypt the confirmation payload with connection's provider public key
    private static func encryptedData(requestData: SEConfirmAuthorizationRequestData) -> SEEncryptedData? {
        guard let data = [
            SENetKeys.authorizationCode: requestData.authorizationCode,
            ApiConstants.userAuthorizationType: requestData.authorizationType,
            ApiConstants.geolocation: requestData.geolocation
        ].jsonString else { return nil }

        return try? SECryptoHelper.encrypt(data, tag: "\(requestData.connectionGuid)_provider_public_key")
    }
}
