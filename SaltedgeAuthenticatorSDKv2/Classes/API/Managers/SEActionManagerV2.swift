//
//  SEActionManagerV2
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

public struct SEActionManagerV2 {
    public static func submitAction(
        data: SEActionRequestDataV2,
        onSuccess success: @escaping HTTPServiceSuccessClosure<SESubmitActionResponseV2>,
        onFailure failure: @escaping FailureBlock
    ) {
        HTTPService<SESubmitActionResponseV2>.execute(
            request: SEActionRouterV2.submit(data, parameters(requestData: data)),
            success: success,
            failure: failure
        )
    }

    private static func parameters(requestData: SEActionRequestDataV2) -> [String: Any] {
        return [
            SENetKeys.data: [
                ApiConstants.providerId: requestData.providerId,
                ApiConstants.actionId: requestData.actionId,
                ApiConstants.connectionId: requestData.connectionId
            ],
            ParametersKeys.exp: Date().addingTimeInterval(5.0 * 60.0).utcSeconds
        ]
    }
}
