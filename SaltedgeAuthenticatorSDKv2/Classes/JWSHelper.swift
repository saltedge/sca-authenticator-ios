//
//  JWSHelper
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
import JOSESwift
import SEAuthenticatorCore

struct JWSHelper {
    static func sign(params: [String: Any]?, guid: String) -> String? {
        guard let payloadParams = params,
              let payloadBody = ParametersSerializer.createBody(parameters: payloadParams),
              let privateKey = privateKey(for: SETagHelper.create(for: guid)),
              let signer = Signer(signingAlgorithm: .RS256, key: privateKey) else { return nil }

        let header = JWSHeader(algorithm: .RS256)

        guard let jws = try? JWS(header: header, payload: Payload(payloadBody), signer: signer) else { return nil }

        let splittedSerializedJwsString = jws.compactSerializedString.split(separator: ".")

        return splittedSerializedJwsString[0] + ".." + splittedSerializedJwsString[2]
    }

    static func privateKey(for tag: String) -> SecKey? {
        do {
            return try SECryptoHelper.privateKey(for: tag)
        } catch {
            print(error.localizedDescription)
        }

        return nil
    }
}
