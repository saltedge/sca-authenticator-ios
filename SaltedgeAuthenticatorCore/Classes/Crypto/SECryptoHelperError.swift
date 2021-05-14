//
//  SECryptoHelperError.swift
//  SaltedgeAuthenticatorSDK
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright (c) 2019 Salt Edge Inc.
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


import Foundation

enum SECryptoHelperError: Error {
    case errorGeneratingRandomBytes
    case errorCreatingData(fromBase64: String)
    case couldNotEncryptChunk(at: Int)
    case couldNotDecryptChunk(at: Int)

    var localizedDescription: String {
        var message = ""
        switch self {
        case .errorCreatingData(let string):
            message = "from base 64 encoded \(string)"
        case .couldNotEncryptChunk(let index):
            message = "at index: \(index)"
        case .couldNotDecryptChunk(let index):
            message = "at index: \(index)"
        default:
            break
        }
        return "\(String(describing: type(of: self))).\(String(describing: self)) \(message)"
    }
}

enum SEAesCipherError: Error {
    case couldNotCreateData(from: String)
    case couldNotCreateString(fromBase64: String)
    case couldNotCreateEncryptedData(fromBase64: String)
    case couldNotCreateDecodedString(fromData: Data)
    case noKeyProvided
    case noIvProvided

    var localizedDescription: String {
        var message = ""
        switch self {
        case .couldNotCreateData(let string),
             .couldNotCreateString(let string),
             .couldNotCreateEncryptedData(let string):
            message = string
        case .couldNotCreateDecodedString(let data):
            message = data.base64EncodedString()
        default:
            break
        }

        return "\(String(describing: type(of: self))).\(String(describing: self)) \(message)"
    }
}

enum SESecKeyHelperError: Error {
    case couldNotObtainKey(for: String)
    case couldNotObtainKeyData(for: String)
    case couldNotAddToKeychain
    
    var localizedDescription: String {
        return "\(String(describing: type(of: self))).\(String(describing: self))"
    }
}

