//
//  SECryptoHelper.swift
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
import CryptoSwift

public typealias KeyTag = String
public typealias KeyPair = (publicKey: SecKey, privateKey: SecKey)

public struct SECryptoHelper {
    // MARK: - Public Methods

    /*
     Create RSA key pair and store it in Keychain
     
     - parameters:
      - tag: An unique identifier for a newly generated key pair, by which the key could be retrieved from Keychain
    */
    @discardableResult
    public static func createKeyPair(with tag: KeyTag) -> KeyPair? {
        SecKeyHelper.deleteKey(tag)
        SecKeyHelper.deleteKey(tag.privateTag)

        return SecKeyHelper.generateKeyPair(tag: tag)
    }

    /*
     Convert private key from asymmetric key pair to pem string
     
     - parameters:
      - tag: An unique identifier by which was created the private key
    */
    public static func privateKeyToPem(tag: KeyTag) -> String? {
        return try? privateKeyData(for: tag.privateTag).string
    }

    /*
     Convert public key from asymmetric key pair to pem string
     
     - parameters:
      - tag: An unique identifier by which was created the public key
    */
    public static func publicKeyToPem(tag: KeyTag) -> String? {
        return try? publicKeyData(for: tag).string
    }

    /*
      Converts string which contains private key in PEM format to SecKey object

     - parameters:
      - pem: Key in pem format
      - isPublic: Type of the key
      - tag: An unique identifier by which the key could be retrieved from Keychain
    */
    @discardableResult
    public static func createKey(from pem: String, isPublic: Bool, tag: String) -> SecKey? {
        SecKeyHelper.deleteKey(tag)
        SecKeyHelper.deleteKey(tag.privateTag)

        return try? SecKeyHelper.createKey(from: pem, isPublic: isPublic, tag: tag)
    }

    @discardableResult
    public static func deleteKeyPair(with tag: KeyTag) -> Bool {
        SecKeyHelper.deleteKey(tag.privateTag)

        return SecKeyHelper.deleteKey(tag)
    }

    public static func encrypt(_ message: String, tag: KeyTag) throws -> SEEncryptedData {
        let key = try generateRandomBytes(count: 32)
        let iv = try generateRandomBytes(count: 16)

        let encryptedKey = try publicEncrypt(data: key, keyForTag: tag)
        let encryptedIv = try publicEncrypt(data: iv, keyForTag: tag)

        return SEEncryptedData(
            data: try AesCipher.encrypt(message: message, key: key, iv: iv),
            key: encryptedKey.base64EncodedString(),
            iv: encryptedIv.base64EncodedString()
        )
    }

    public static func decrypt(_ encryptedData: SEEncryptedData, tag: KeyTag) throws -> String {
        let privateKey = try SecKeyHelper.obtainKey(for: tag.privateTag)

        return try decrypt(encryptedData, privateKey: privateKey)
    }

    public static func decrypt(_ encryptedData: SEEncryptedData, privateKey: SecKey) throws -> String {
        let decryptedKey = try privateDecrypt(message: encryptedData.key, privateKey: privateKey)
        let decryptedIv = try privateDecrypt(message: encryptedData.iv, privateKey: privateKey)

        return try AesCipher.decrypt(data: encryptedData.data, key: decryptedKey, iv: decryptedIv)
    }

    public static func publicKeyData(for tag: KeyTag) throws -> Data {
        return try SecKeyHelper.obtainKeyData(for: tag)
    }

    public static func privateKeyData(for tag: KeyTag) throws -> Data {
        return try SecKeyHelper.obtainKeyData(for: tag.privateTag)
    }

    public static func publicKey(for tag: KeyTag) throws -> SecKey {
        return try SecKeyHelper.obtainKey(for: tag)
    }

    public static func privateKey(for tag: KeyTag) throws -> SecKey {
        return try SecKeyHelper.obtainKey(for: tag.privateTag)
    }

    // MARK: - Private Methods
    private static func privateDecrypt(message: String, privateKey: SecKey) throws -> Data {
        guard let data = Data(base64Encoded: message.replacingOccurrences(of: "\n", with: "")) else {
            throw SECryptoHelperError.errorCreatingData(fromBase64: message)
        }

        let blockSize = SecKeyGetBlockSize(privateKey)

        var encryptedDataAsArray = [UInt8](repeating: 0, count: data.count)
        (data as NSData).getBytes(&encryptedDataAsArray, length: data.count)

        var decryptedDataBytes = [UInt8](repeating: 0, count: 0)
        var idx = 0
        while idx < encryptedDataAsArray.count {

            let idxEnd = min(idx + blockSize, encryptedDataAsArray.count)
            let chunkData = [UInt8](encryptedDataAsArray[idx..<idxEnd])

            var decryptedDataBuffer = [UInt8](repeating: 0, count: blockSize)
            var decryptedDataLength = blockSize

            let status = SecKeyDecrypt(privateKey, .PKCS1, chunkData, idxEnd-idx, &decryptedDataBuffer, &decryptedDataLength)
            guard status == noErr else {
                throw SECryptoHelperError.couldNotDecryptChunk(at: idx)
            }

            decryptedDataBytes += [UInt8](decryptedDataBuffer[0..<decryptedDataLength])

            idx += blockSize
        }

        let uint8Pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: decryptedDataBytes.count)
        uint8Pointer.initialize(from: &decryptedDataBytes, count: decryptedDataBytes.count)

        return Data(bytes: uint8Pointer, count: decryptedDataBytes.count)
    }

    private static func publicEncrypt(data: Data, keyForTag: KeyTag) throws -> Data {
        let publicKey = try SecKeyHelper.obtainKey(for: keyForTag)

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

    private static func generateRandomBytes(count: Int) throws -> Data {
        let keyData = Data(count: count)
        var newData = keyData
        let result = newData.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, keyData.count, $0.baseAddress!) }
        if result == errSecSuccess {
            return keyData
        } else {
            throw SECryptoHelperError.errorGeneratingRandomBytes
        }
    }
}

private struct AesCipher {
    static func encrypt(message: String, key: Data, iv: Data) throws -> String {
        guard let data = message.data(using: .utf8) else {
            throw SEAesCipherError.couldNotCreateData(from: message)
        }

        let keyArray = [UInt8](key)
        let ivArray = [UInt8](iv)

        do {
            let enc = try AES(key: keyArray, blockMode: CBC(iv: ivArray)).encrypt(data.bytes)
            let encData = NSData(bytes: enc, length: Int(enc.count))
            let base64String: String = encData.base64EncodedString(options: [])

            return String(base64String)
        } catch {
            throw error
        }
    }

    static func decrypt(data: String, key: Data, iv: Data) throws -> String {
        guard let encryptedData = Data(base64Encoded: data, options: [.ignoreUnknownCharacters]) else {
            throw SEAesCipherError.couldNotCreateEncryptedData(fromBase64: data)
        }

        let keyArray = [UInt8](key)
        let ivArray = [UInt8](iv)

        if keyArray.isEmpty { throw SEAesCipherError.noKeyProvided }
        if iv.isEmpty { throw SEAesCipherError.noIvProvided }
        do {
            let dec = try AES(key: keyArray, blockMode: CBC(iv: ivArray)).decrypt(encryptedData.bytes)
            let decData = NSData(bytes: dec, length: Int(dec.count))

            guard let result = String(data: decData as Data, encoding: .utf8) else {
                throw SEAesCipherError.couldNotCreateDecodedString(fromData: decData as Data)
            }

            return String(result)
        } catch {
            throw error
        }
    }
}

private struct SecKeyHelper {
    static func generateKeyPair(tag: KeyTag) -> KeyPair? {
        let privateAttributes = [
            String(kSecAttrIsPermanent): true,
            String(kSecAttrApplicationTag): tag.privateTag,
            String(kSecAttrAccessible): kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ] as [String: Any]

        let publicAttributes = [
            String(kSecAttrIsPermanent): true,
            String(kSecAttrApplicationTag): tag,
            String(kSecAttrAccessible): kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ] as [String: Any]

        let pairAttributes = [
            String(kSecAttrKeyType): kSecAttrKeyTypeRSA,
            String(kSecAttrKeySizeInBits): 2048 as UInt,
            String(kSecPublicKeyAttrs): publicAttributes,
            String(kSecPrivateKeyAttrs): privateAttributes
        ] as [String: Any]

        var publicRef, privateRef: SecKey?
        switch SecKeyGeneratePair(pairAttributes as CFDictionary, &publicRef, &privateRef) {
        case noErr:
            if let publicKey = publicRef, let privateKey = privateRef {
                return (publicKey, privateKey)
            }
        default: break
        }
        return nil
    }

    static func createKey(from pem: String, isPublic: Bool, tag: String) throws -> SecKey {
        let base64Encoded = base64String(pemEncoded: pem)

        guard let data = Data(base64Encoded: base64Encoded, options: [.ignoreUnknownCharacters]) else {
            throw SECryptoHelperError.errorCreatingData(fromBase64: base64Encoded)
        }

        let keyClass = isPublic ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate

        let persistKey = UnsafeMutablePointer<AnyObject?>(mutating: nil)

        let keyAddDict: [String: Any] = [
            String(kSecClass): kSecClassKey,
            String(kSecAttrApplicationTag): tag,
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

            // swiftlint:disable:next force_cast
            return (ref as! SecKey)
        default:
            throw SESecKeyHelperError.couldNotObtainKey(for: tag)
        }
    }

    @discardableResult
    static func deleteKey(_ tag: KeyTag) -> Bool {
        let query: [String: AnyObject] = [
            String(kSecAttrKeyType): kSecAttrKeyTypeRSA,
            String(kSecClass): kSecClassKey as CFString,
            String(kSecAttrApplicationTag): tag as CFString
        ]

        return SecItemDelete(query as CFDictionary) == noErr
    }

    static func base64String(pemEncoded pemString: String) -> String {
        return pemString.components(separatedBy: "\n").filter { line in
            return !line.hasPrefix("-----BEGIN") && !line.hasPrefix("-----END")
        }.joined(separator: "")
    }

    static func pem(_ filename: String) -> String {
        let path = Bundle.main.path(forResource: filename, ofType: "pem")!
        // swiftlint:disable:next force_try
        let pemString = try! String(contentsOfFile: path, encoding: .utf8)
        return pemString
    }
}

// MARK: - Public Extensions
public extension Data {
    var string: String {
        let beginPublicKey = "-----BEGIN PUBLIC KEY-----\n"
        let endPublicKey = "\n-----END PUBLIC KEY-----\n"
        let base64PublicKey = dataByPrependingX509Header()
            .base64EncodedString(options: [.lineLength64Characters, .endLineWithLineFeed])

        return (beginPublicKey + base64PublicKey + endPublicKey)
    }
}

// MARK: - Private Extensions
public extension Data {
    func dataByPrependingX509Header() -> Data {
        let result = NSMutableData()

        let encodingLength: Int = (self.count + 1).encodedOctets().count
        let OID: [CUnsignedChar] = [0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
                                    0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00]

        var builder: [CUnsignedChar] = []

        // ASN.1 SEQUENCE
        builder.append(0x30)

        // Overall size, made of OID + bitstring encoding + actual key
        let size = OID.count + 2 + encodingLength + self.count
        let encodedSize = size.encodedOctets()
        builder.append(contentsOf: encodedSize)
        result.append(builder, length: builder.count)
        result.append(OID, length: OID.count)
        builder.removeAll(keepingCapacity: false)

        builder.append(0x03)
        builder.append(contentsOf: (self.count + 1).encodedOctets())
        builder.append(0x00)
        result.append(builder, length: builder.count)

        // Actual key bytes
        result.append(self)

        return result as Data
    }
}

extension NSInteger {
    func encodedOctets() -> [CUnsignedChar] {
        // Short form
        if self < 128 {
            return [CUnsignedChar(self)]
        }

        // Long form
        let i = Int(log2(Double(self)) / 8 + 1)
        var len = self
        var result: [CUnsignedChar] = [CUnsignedChar(i + 0x80)]

        for _ in 0..<i {
            result.insert(CUnsignedChar(len & 0xFF), at: 1)
            len = len >> 8
        }

        return result
    }
}

private extension KeyTag {
    var privateTag: KeyTag {
        return self + ".private"
    }
}
