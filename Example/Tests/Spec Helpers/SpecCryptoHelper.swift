//
//  SpecCryptoHelper.swift
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
import SEAuthenticatorCore
@testable import SEAuthenticator

struct SpecCryptoHelper {
    static func obtainKeyData(for tag: KeyTag) throws -> Data {
        var keyRef: AnyObject?
        let query: [String: AnyObject] = [
            String(kSecAttrKeyType): kSecAttrKeyTypeRSA,
            String(kSecReturnData): kCFBooleanTrue as CFBoolean,
            String(kSecClass): kSecClassKey as CFString,
            String(kSecAttrApplicationTag): tag as CFString
        ]

        switch SecItemCopyMatching(query as CFDictionary, &keyRef) {
        case noErr:
            guard let ref = keyRef as? Data else { throw SESecKeyHelperError.couldNotObtainKeyData(for: tag) }

            return ref
        default:
            throw SESecKeyHelperError.couldNotObtainKeyData(for: tag)
        }
    }

    static func deleteKey(_ tag: KeyTag) -> Bool {
        let query: [String: AnyObject] = [
            String(kSecAttrKeyType): kSecAttrKeyTypeRSA,
            String(kSecClass): kSecClassKey as CFString,
            String(kSecAttrApplicationTag): tag as CFString]

        return SecItemDelete(query as CFDictionary) == noErr
    }

    static func obtainKey(for tag: KeyTag) throws -> SecKey {
        var keyRef: AnyObject?
        let query: [String: AnyObject] = [
            String(kSecAttrKeyType): kSecAttrKeyTypeRSA,
            String(kSecReturnRef): kCFBooleanTrue as CFBoolean,
            String(kSecClass): kSecClassKey as CFString,
            String(kSecAttrApplicationTag): tag as CFString
        ]

        switch SecItemCopyMatching(query as CFDictionary, &keyRef) {

        case noErr:
            guard let ref = keyRef else { throw SESecKeyHelperError.couldNotObtainKey(for: tag) }

            return (ref as! SecKey)
        default:
            throw SESecKeyHelperError.couldNotObtainKey(for: tag)
        }
    }

    private static func base64String(pemEncoded pemString: String) -> String {
        return pemString.components(separatedBy: "\n").filter { line in
            return !line.hasPrefix("-----BEGIN") && !line.hasPrefix("-----END")
        }.joined(separator: "")
    }

    static func createKey(from pemEncoded: String, isPublic: Bool, tag: String) throws -> SecKey {
        _ = deleteKey(tag)
        let base64Encoded = base64String(pemEncoded: pemEncoded)

        guard let data = Data(base64Encoded: base64Encoded, options: [.ignoreUnknownCharacters]) else {
            throw SECryptoHelperError.errorCreatingData(fromBase64: base64Encoded)
        }

        let keyClass = isPublic ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate

        let persistKey = UnsafeMutablePointer<AnyObject?>(mutating: nil)

        let keyAddDict: [String: Any] = [
            String(kSecClass): kSecClassKey,
            String(kSecAttrApplicationTag): tag as CFString,
            String(kSecAttrKeyType): kSecAttrKeyTypeRSA,
            String(kSecValueData): data as CFData,
            String(kSecAttrKeyClass): keyClass,
            String(kSecReturnPersistentRef): true as CFBoolean,
            String(kSecAttrAccessible): kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let secStatus = SecItemAdd(keyAddDict as CFDictionary, persistKey)
        guard secStatus == errSecSuccess || secStatus == errSecDuplicateItem else {
            throw SESecKeyHelperError.couldNotAddToKeychain
        }

        return try obtainKey(for: tag)
    }

    static func publicEncrypt(data: Data, keyForTag: KeyTag) throws -> Data {
        let publicKey = try obtainKey(for: keyForTag)

        let blockSize = SecKeyGetBlockSize(publicKey)
        let maxChunkSize = blockSize - 11 // Since PKCS1 padding is used

        var decryptedDataAsArray = [UInt8](repeating: 0, count: data.count)
        (data as NSData).getBytes(&decryptedDataAsArray, length: data.count)

        var encryptedDataBytes = [UInt8](repeating: 0, count: 0)
        var idx = 0
        while idx < decryptedDataAsArray.count {

            let idxEnd = min(idx + maxChunkSize, decryptedDataAsArray.count)
            let chunkData = [UInt8](decryptedDataAsArray[idx..<idxEnd])

            var encryptedDataBuffer = [UInt8](repeating: 0, count: blockSize)
            var encryptedDataLength = blockSize

            let status = SecKeyEncrypt(publicKey, .PKCS1, chunkData, chunkData.count, &encryptedDataBuffer, &encryptedDataLength)

            guard status == noErr else {
                throw SECryptoHelperError.couldNotEncryptChunk(at: idx)
            }

            encryptedDataBytes += encryptedDataBuffer

            idx += maxChunkSize
        }

        let uint8Pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: encryptedDataBytes.count)
        uint8Pointer.initialize(from: &encryptedDataBytes, count: encryptedDataBytes.count)

        return Data(bytes: uint8Pointer, count: encryptedDataBytes.count)
    }
}

extension Data {
    var stringMock: String {
        let beginPublicKey = "-----BEGIN PUBLIC KEY-----\n"
        let endPublicKey = "\n-----END PUBLIC KEY-----\n"
        let base64PublicKey = dataByPrependingX509Header()
            .base64EncodedString(options: [.lineLength64Characters, .endLineWithLineFeed])
        return beginPublicKey + base64PublicKey + endPublicKey
    }
}

