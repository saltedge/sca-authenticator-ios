//
//  SignatureHelper.swift
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
import CommonCrypto
import SEAuthenticatorCore

struct SignatureHelper {
    static func signedPayload(method: HTTPMethod,
                              urlString: String,
                              guid: GUID,
                              expiresAt: Int,
                              params: [String: Any]?) -> String? {
        let bodyString: String
        if let payloadParams = params, let payloadBody = ParametersSerializer.createBody(parameters: payloadParams) {
            bodyString = String(data: payloadBody, encoding: .utf8) ?? ""
        } else {
            bodyString = ""
        }

        let payload = "\(method)|\(urlString)|\(expiresAt)|\(bodyString)"

        return sign(message: payload, guid: guid)
    }

    static func sign(message: String, guid: GUID) -> String? {
        guard let messageData = message.data(using: .utf8),
            let privateKey = privateKey(for: SETagHelper.create(for: guid)) else { return nil }

        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        let hashBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: digestLength)

        CC_SHA256([UInt8](messageData), CC_LONG(messageData.count), hashBytes)

        let blockSize = SecKeyGetBlockSize(privateKey)
        var signatureBytes = [UInt8](repeating: 0, count: blockSize)
        var signatureDataLength = blockSize
        let status = SecKeyRawSign(privateKey, .PKCS1SHA256, hashBytes, digestLength, &signatureBytes, &signatureDataLength)

        guard status == noErr else { return nil }

        let data = Data(bytes: signatureBytes, count: signatureDataLength)

        return data.base64EncodedString()
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
