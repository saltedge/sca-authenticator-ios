//
//  SpecUtils.swift
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
import SEAuthenticator
import SEAuthenticatorV2
import SEAuthenticatorCore

struct SpecUtils {
    static func createConnection(id: ID, apiVersion: ApiVersion = "1", geolocationRequired: Bool = true) -> Connection {
        let connection = Connection()
        connection.id = id
        connection.baseUrlString = "url.com"
        connection.apiVersion = apiVersion
        connection.geolocationRequired.value = geolocationRequired
        ConnectionRepository.save(connection)
        _ = SECryptoHelper.createKeyPair(with: SETagHelper.create(for: connection.guid))

        return connection
    }

    static func privateKey(for tag: String) -> SecKey? {
        do {
            return try SECryptoHelper.privateKey(for: tag)
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }

    static func createAuthResponse(with authMessage: [String: Any], id: ID, guid: GUID) -> SEAuthorizationData {
        let encryptedMessage = try! SECryptoHelper.encrypt(authMessage.jsonString!, tag: SETagHelper.create(for: guid))

        let encryptedData = SEEncryptedData(data: encryptedMessage.data, key: encryptedMessage.key, iv: encryptedMessage.iv, connectionId: id)

        return encryptedData.decryptedAuthorizationData!
    }

    static func createAuthResponseV2(
        with authMessage: [String: Any],
        authorizationId: Int,
        connectionId: Int,
        guid: GUID,
        status: String = "pending"
    ) -> SEAuthorizationDataV2 {
        let encryptedData = try! SECryptoHelper.encrypt(authMessage.jsonString!, tag: SETagHelper.create(for: guid))

        let dict: [String: Any] = [
            "data": encryptedData.data,
            "key": encryptedData.key,
            "iv": encryptedData.iv,
            "id": authorizationId,
            "connection_id": connectionId,
            "status": status
        ]

        let response = SpecDecodableModel<SEEncryptedAuthorizationData>.create(from: dict)!
        return response.decryptedAuthorizationDataV2!
    }

    static func createNotEncryptedAuthResponseV2(
        with authMessage: [String: Any],
        authorizationId: Int,
        connectionId: Int,
        guid: GUID,
        status: AuthorizationStatus
    ) -> SEAuthorizationDataV2 {
        return SEAuthorizationDataV2(id: "\(authorizationId)", connectionId: "\(connectionId)", status: status)
    }

    
    public static var publicKeyPem: String {
        "-----BEGIN PUBLIC KEY-----\n" +
        "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAppVU/nZZVewUCRVLz51X\n" +
        "iKcliziIOb5/ReqHH82ikgC517/7Qo/cBFK+/iOC+yDgULkJE3SMhG85JoCqeX7j\n" +
        "YzeILe5LLgqAxLCOjQFnkQDaHwP2WShU8WQifZ58UY5Th2GCKScFrsLxPr8HLWJH\n" +
        "cPC6qicuOmgvyT64SvWFh8l5nHWcx/RA7e5Z4eCRntqyVDv622/vYybNInFMvqB+\n" +
        "oEGOhEyh/qCYmIumEH3QH91eqCd05/Z9PtugH08TqRPDL6s5GunfTsBHYhJdxDTc\n" +
        "qh0etk+TnUqYON7jOXDAN7L8y5VI/UELVONBJy8MzcyER1pyPhrnCDMaKX6+LcpB\n" +
        "owIDAQAB\n" +
        "-----END PUBLIC KEY-----\n"
    }
}

public struct SpecDecodableModel<T: Decodable> {
    public static func create(from fixture: [String: Any]) -> T? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategyFormatters = [DateUtils.dateFormatter, DateUtils.ymdDateFormatter]
        let fixtureData = Data(fixture.jsonString!.utf8)
        return try? decoder.decode(T.self, from: fixtureData)
    }
}

private extension JSONDecoder {
    var dateDecodingStrategyFormatters: [DateFormatter]? {
        get {
            return nil
        }
        set {
            guard let formatters = newValue else { return }

            self.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)

                for formatter in formatters {
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                }

                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
            }
        }
    }
}
