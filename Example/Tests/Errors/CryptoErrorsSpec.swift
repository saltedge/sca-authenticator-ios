//
//  CryptoErrorsSpec.swift
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

import Quick
import Nimble
@testable import SEAuthenticator

class CryptoErrorsSpec: BaseSpec {
    override func spec() {
        describe("SECryptoHelperError") {
            it("should return localized descripiton for every error") {
                let description: (SECryptoHelperError) -> (String) = { error in
                    var message = ""
                    switch error {
                    case .errorCreatingData(let string):
                       message = "from base 64 encoded \(string)"
                    case .couldNotEncryptChunk(let index):
                        message = "at index: \(index)"
                    case .couldNotDecryptChunk(let index):
                        message = "at index: \(index)"
                    default:
                        break
                    }
                    return "\(String(describing: type(of: error))).\(String(describing: error)) \(message)"
                }

                let errorGeneratingRandomBytes = SECryptoHelperError.errorGeneratingRandomBytes
                let errorCreatingData = SECryptoHelperError.errorCreatingData(fromBase64: "test")
                let couldNotEncrypt = SECryptoHelperError.couldNotEncryptChunk(at: 0)
                let couldNotDecrypt = SECryptoHelperError.couldNotDecryptChunk(at: 0)

                expect(errorGeneratingRandomBytes.localizedDescription).to(equal(description(errorGeneratingRandomBytes)))
                expect(errorCreatingData.localizedDescription).to(equal(description(errorCreatingData)))
                expect(couldNotEncrypt.localizedDescription).to(equal(description(couldNotEncrypt)))
                expect(couldNotDecrypt.localizedDescription).to(equal(description(couldNotDecrypt)))
            }
        }

        describe("SEAesCipherError") {
            it("should return localized descripiton for every error") {
                let description: (SEAesCipherError) -> (String) = { error in
                    var message = ""
                    switch error {
                    case .couldNotCreateData(let string),
                         .couldNotCreateString(let string),
                         .couldNotCreateEncryptedData(let string):
                       message = string
                    case .couldNotCreateDecodedString(let data):
                        message = data.base64EncodedString()
                    default:
                        break
                    }

                    return "\(String(describing: type(of: error))).\(String(describing: error)) \(message)"
                }

                let couldNotCreateData = SEAesCipherError.couldNotCreateData(from: "some data")
                let couldNotCreateString = SEAesCipherError.couldNotCreateString(fromBase64: "some string")
                let couldNotCreateEncryptedData = SEAesCipherError.couldNotCreateEncryptedData(fromBase64: "string for encrypted data")
                let couldNotCreateDecodedString = SEAesCipherError.couldNotCreateDecodedString(fromData: "encoded string".data(using: .utf8)!)
                let noKeyProvided = SEAesCipherError.noKeyProvided
                let noIvProvided = SEAesCipherError.noKeyProvided

                expect(couldNotCreateData.localizedDescription).to(equal(description(couldNotCreateData)))
                expect(couldNotCreateString.localizedDescription).to(equal(description(couldNotCreateString)))
                expect(couldNotCreateEncryptedData.localizedDescription).to(equal(description(couldNotCreateEncryptedData)))
                expect(couldNotCreateDecodedString.localizedDescription).to(equal(description(couldNotCreateDecodedString)))
                expect(noKeyProvided.localizedDescription).to(equal(description(noKeyProvided)))
                expect(noIvProvided.localizedDescription).to(equal(description(noIvProvided)))
            }
        }

        describe("SESecKeyHelperError") {
            let description: (SESecKeyHelperError) -> (String) = { error in
                return "\(String(describing: type(of: error))).\(String(describing: error))"
            }

            let couldNotObtainKey = SESecKeyHelperError.couldNotObtainKey(for: "test")
            let couldNotObtainKeyData = SESecKeyHelperError.couldNotObtainKeyData(for: "test")

            expect(SESecKeyHelperError.couldNotAddToKeychain.localizedDescription).to(equal(description(.couldNotAddToKeychain)))
            expect(couldNotObtainKey.localizedDescription).to(equal(description(couldNotObtainKey)))
            expect(couldNotObtainKeyData.localizedDescription).to(equal(description(couldNotObtainKeyData)))
        }
    }
}
