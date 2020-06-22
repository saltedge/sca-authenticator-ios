//
//  SEAuthorizationManager.swift
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2019 Salt Edge Inc.
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

public struct SEAuthorizationManager {
    public static func getEncryptedAuthorizations(
        data: SEBaseAuthenticatedRequestData,
        onSuccess success: @escaping HTTPServiceSuccessClosure<SEEncryptedListResponse>,
        onFailure failure: @escaping FailureBlock
    ) {
        HTTPService<SEEncryptedListResponse>.execute(
            request: SEAuthorizationRouter.list(data),
            success: success,
            failure: failure
        )
    }

    public static func getEncryptedAuthorization(
        data: SEBaseAuthenticatedWithIdRequestData,
        onSuccess success: @escaping HTTPServiceSuccessClosure<SEEncryptedDataResponse>,
        onFailure failure: @escaping FailureBlock
    ) {
        HTTPService<SEEncryptedDataResponse>.execute(
            request: SEAuthorizationRouter.getAuthorization(data),
            success: success,
            failure: failure
        )
    }

    public static func confirmAuthorization(
        data: SEConfirmAuthorizationRequestData,
        onSuccess success: @escaping HTTPServiceSuccessClosure<SEConfirmAuthorizationResponse>,
        onFailure failure: @escaping FailureBlock
    ) {
        HTTPService<SEConfirmAuthorizationResponse>.execute(
            request: SEAuthorizationRouter.confirm(data),
            success: success,
            failure: failure
        )
    }

    public static func denyAuthorization(
        data: SEConfirmAuthorizationRequestData,
        onSuccess success: @escaping HTTPServiceSuccessClosure<SEConfirmAuthorizationResponse>,
        onFailure failure: @escaping FailureBlock
    ) {
        HTTPService<SEConfirmAuthorizationResponse>.execute(
            request: SEAuthorizationRouter.deny(data),
            success: success,
            failure: failure
        )
    }
}
