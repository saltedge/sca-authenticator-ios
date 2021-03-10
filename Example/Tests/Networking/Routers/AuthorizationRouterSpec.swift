//
//  AuthorizationRouterSpec.swift
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

class AuthorizationRouterSpec: BaseSpec {
    override func spec() {
        let baseUrl = URL(string: "base.com")!
        let baseUrlPath = "api/authenticator/v1/authorizations"
        let expiresAt = Date().addingTimeInterval(5.0 * 60.0).utcSeconds

        describe("AuthorizationsRouter") {
            context("when it's .list") {
                it("should create a valid url request") {
                    let signature = SignatureHelper.signedPayload(
                        method: .get,
                        urlString: baseUrl.appendingPathComponent(baseUrlPath).absoluteString,
                        guid: "tag",
                        expiresAt: expiresAt,
                        params: nil
                    )

                    let headers = Headers.signedRequestHeaders(
                        token: "token",
                        expiresAt: expiresAt,
                        signature: signature,
                        appLanguage: "en"
                    )

                    let expectedRequest = URLRequestBuilder.buildUrlRequest(
                        with: baseUrl.appendingPathComponent(baseUrlPath),
                        method: HTTPMethod.get.rawValue,
                        headers: headers,
                        encoding: .url
                    )

                    let expectedData = SEBaseAuthenticatedRequestData(
                        url: baseUrl,
                        connectionGuid: "tag",
                        accessToken: "token",
                        appLanguage: "en"
                    )
                
                    let request = SEAuthorizationRouter.list(expectedData).asURLRequest()

                    expect(request).to(equal(expectedRequest))
                }
            }

            context("when it's .getAuthorization") {
                it("should create a valid url request") {
                    let data = SEBaseAuthenticatedWithIdRequestData(
                        url: baseUrl,
                        connectionGuid: "123guid",
                        accessToken: "accessToken",
                        appLanguage: "en",
                        entityId: "1"
                    )

                    let signature = SignatureHelper.signedPayload(
                        method: .get,
                        urlString: baseUrl.appendingPathComponent("\(baseUrlPath)/\(data.entityId)").absoluteString,
                        guid: "123guid",
                        expiresAt: expiresAt,
                        params: nil
                    )

                    let headers = Headers.signedRequestHeaders(
                        token: "accessToken",
                        expiresAt: expiresAt,
                        signature: signature,
                        appLanguage: "en"
                    )

                    let expectedRequest = URLRequestBuilder.buildUrlRequest(
                        with: baseUrl.appendingPathComponent("\(baseUrlPath)/\(data.entityId)"),
                        method: HTTPMethod.get.rawValue,
                        headers: headers,
                        encoding: .url
                    )

                    let request = SEAuthorizationRouter.getAuthorization(data).asURLRequest()

                    expect(request).to(equal(expectedRequest))
                }
            }

            context("when it's .confirm") {
                it("should create a valid url request") {
                    let data = SEConfirmAuthorizationRequestData(
                        url: baseUrl,
                        connectionGuid: "123guid",
                        accessToken: "accessToken",
                        appLanguage: "en",
                        authorizationId: "1",
                        authorizationCode: "code",
                        geolocation: "GEO:52.506931;13.144558",
                        authorizationType: "biometrics"
                    )

                    let params = RequestParametersBuilder.confirmAuthorization(true, authorizationCode: data.authorizationCode)

                    let signature = SignatureHelper.signedPayload(
                        method: .put,
                        urlString: data.url.appendingPathComponent("\(baseUrlPath)/\(data.entityId)").absoluteString,
                        guid: data.connectionGuid,
                        expiresAt: expiresAt,
                        params: params
                    )

                    let headers = Headers.signedRequestHeaders(
                        token: data.accessToken,
                        expiresAt: expiresAt,
                        signature: signature,
                        appLanguage: "en"
                    )
                    .addLocationHeader(geolocation: "GEO:52.506931;13.144558")
                    .addAuthorizationTypeHeader(authorizationType: "biometrics")

                    let expectedRequest = URLRequestBuilder.buildUrlRequest(
                        with: baseUrl.appendingPathComponent("\(baseUrlPath)/\(data.entityId)"),
                        method: HTTPMethod.put.rawValue,
                        headers: headers,
                        params: params,
                        encoding: .json
                    )

                    let request = SEAuthorizationRouter.confirm(data).asURLRequest()

                    expect(request).to(equal(expectedRequest))
                }
            }

            context("when it's .deny") {
                it("should create a valid url request") {
                    let data = SEConfirmAuthorizationRequestData(
                        url: baseUrl,
                        connectionGuid: "123guid",
                        accessToken: "accessToken",
                        appLanguage: "en",
                        authorizationId: "1",
                        authorizationCode: "code",
                        geolocation: "GEO:52.506931;13.144558",
                        authorizationType: "biometrics"
                    )
                    
                    let params = RequestParametersBuilder.confirmAuthorization(false, authorizationCode: data.authorizationCode)
                    
                    let signature = SignatureHelper.signedPayload(
                        method: .put,
                        urlString: data.url.appendingPathComponent("\(baseUrlPath)/\(data.entityId)").absoluteString,
                        guid: data.connectionGuid,
                        expiresAt: expiresAt,
                        params: params
                    )
                    
                    let headers = Headers.signedRequestHeaders(
                        token: data.accessToken,
                        expiresAt: expiresAt,
                        signature: signature,
                        appLanguage: "en"
                    )
                    .addLocationHeader(geolocation: "GEO:52.506931;13.144558")
                    .addAuthorizationTypeHeader(authorizationType: "biometrics")

                    let expectedRequest = URLRequestBuilder.buildUrlRequest(
                        with: baseUrl.appendingPathComponent("\(baseUrlPath)/\(data.entityId)"),
                        method: HTTPMethod.put.rawValue,
                        headers: headers,
                        params: params,
                        encoding: .json
                    )
                    
                    let request = SEAuthorizationRouter.deny(data).asURLRequest()
                    
                    expect(request).to(equal(expectedRequest))
                }
            }
        }
    }
}
