# Authenticator iOS SDK  

A client of Salt Edge Authenticator API v2 implemeted by Salt Edge SCA Service. Implements Strong Customer Authentication/Dynamic Linking process.

## Requirements

- iOS 10.0+
- Xcode 10.2+
- Swift 5+

## Installation

### CocoaPods

CocoaPods is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website.
To integrate `SaltedgeAuthenticatorSDKv2` into your Xcode project using CocoaPods, specify it in your Podfile:

`pod 'SaltedgeAuthenticatorSDKv2'`

## How to use

Authenticator SDK provide next features:
* [Create connection (Link Bank flow)](#create-connection)
* [Remove connection (Remove Bank)](#remove-connection)
* [Fetch authorizations list](#fetch-authorizations-list)
* [Fetch authorization by ID](#fetch-authorization-by-id)
* [Confirm authorization](#confirm-authorization)
* [Deny authorization](#deny-authorization)
* [Send instant action](#send-instant-action)
* [Get User Consents](#Get-User-Consents)
* [Revoke Consent](#Revoke-Consent)

### Data models

#### Connection
 * `guid` **[string]** - Alias to RSA keypair
 * `id` **[string]** - Unique id received from Authenticator API
 * `name` **[string]** - Provider's name from `SEProviderResponse`
 * `code` **[string]** - Provider's code
 * `logoUrl` **[string]** - Provider's logo url. May be empty
 * `connectUrl` **[string]** - Base url of Authenticator API
 * `accessToken` **[string]** - Access token for accessing Authenticator API resources
 * `status` **[string]** - Connection Status. ACTIVE or INACTIVE

#### SEEncryptedData
 * `algorithm` **[string]** - encryption algorithm and block mode type
 * `iv` **[string]** - an initialization vector of encryption algorithm, this string is encrypted with public key linked to mobile client
 * `key` **[string]** - an secure key of encryption algorithm, this string is encrypted with public key linked to mobile client
 * `data` **[string]** - encrypted payload (Authorization/Consent) with algorithm mentioned above
 * `connection_id` **[string]** - Optional. A unique ID of Mobile Client (Service Connection). Used to decrypt models in the mobile application

#### SEAuthorizationDataV2
 * `id` **[string]** - a unique id of authorization action
 * `connection_id` **[string]** - a unique ID of Connection. Used to decrypt models in the mobile application
 * `title` **[string]** - a human-readable title of authorization action
 * `description` **[string]** - a human-readable description of authorization action
 * `authorization_code` **[string]** - Optional. A unique code for each operation (e.g. payment transaction), specific to the attributes of operation, must be used once
 * ` apiVersion` **[string]** - current version of API
 * `created_at` **[datetime]** - time when the authorization was created
 * `expires_at` **[datetime]** - time when the authorization should expire

 #### SEConsentData
 * `id` **[string]** - a unique id of Consent object
 * `connection_id` **[string]** - a unique ID of Connection. Used to decrypt models in the mobile application
 * `title` **[string]** - a human-readable title of Consent object
 * `status` **[string]** - current Status of Authorization (pending, processing, confirmed, denied, error, timeOut, unavailable, confirm_processing, deny_processing, data)
 * `description` **[string]** - a human-readable description of Consent object (plain text, html, json, etc.)
 * `created_at` **[datetime]** - time when the authorization was created
 * `expires_at` **[datetime]** - time when the authorization should expire

### Responses

##### SEProviderResponseV2
 * `name` **[string]** - Provider's name
 * `code` **[string]** - Provider's code
 * `logoUrl` **[string]** - Optional. Provider's logo url.
 * `baseUrl` **[string]** - Base url of SCA Service
 * `providerId` **[string]** - a unique identificator of Provider
 * `supportEmail` **[string]** -  email address of Provider's Customer Support
 * `publicKey` **[string]** - asymmetric RSA Public Key (in PEM format) linked to the Provider (registered as Client in SCA Service)
 * `geolocationRequired` **[boolean]** - collection of geolocation data is mandatory or not

##### SECreateConnectionResponseV2
 * `authenticationUrl` **[string]** - URL OAuth Authentication Page for future end-user authentication
 * `id` **[string]** - an ID of current connection

##### SEConfirmAuthorizationResponseV2
 * `id` **[string]** - a unique id of authorization
 * `status` **[string]** - current status of authorization model (e.g. pending)

##### SERevokeConnectionResponseV2
 * `id` **[connection_id]** - a unique identifier of Connection of SCA Service

### Create connection

1. Scan QR code

2. Extract qr code content (deep link)
`authenticator://saltedge.com/connect?configuration=https://example.com/configuration`

3. Extract configuration url from deep link.

Use extraction method from `SEConnectHelper.swift`
    ```swift
        let configurationUrl = SEConnectHelper.configuration(from: deepLink)
    ```

4. Fetch Provider Data from configuration url
    - parameters:
      - `url`: the url, which will be use to make request.

    ```swift
        SEProviderManagerV2.fetchProviderData(
            url: configurationUrl,
            onSuccess: { response in
                // handle SEProviderResponseV2
            },
            onFailure: { error in
                // handle error
            }
        )
    ```

5. Create Provider's public key (SecKey)

    ```swift
        SECryptoHelper.createKey(
            from: connection.publicKey,
            isPublic: true,
            tag: connection.providerPublicKeyTag
        )
    ```    

6. Generate new RSA key pair for a new Connection by tag

    ```swift
        SECryptoHelper.createKeyPair(with: SETagHelper.create(for: connection.guid))
    ```

7. Convert Connection's public key to pem

    ```swift
        let connectionPublicKeyPem = SECryptoHelper.publicKeyToPem(tag: SETagHelper.create(for: connection.guid)),
    ```
8.  Encrypt Connection's public key with Provider's public key (step 5)

    ```swift
        let encryptedData = try? SECryptoHelper.encrypt(
            connectionPublicKeyPem,
            tag: connection.providerPublicKeyTag
        )
    ```

9. Create `SECreateConnectionParams` model, where will be created keypair using `tag`.
    - parameters:
      - `providerId`: The id of Connection's Provider
      - `pushToken`: The push token of the devise
      - `connectQuery`: Token which uniquely identifies the user which requires creation of new connection.
      - `encryptedRsaPublicKey`: Connection's public key with Provider's public key (step 8)

    ```swift
        let connectionParams = SECreateConnectionParams(
            providerId: providerId,
            pushToken: pushToken,
            connectQuery: connectQuery,
            encryptedRsaPublicKey: encryptedRsaPublicKey
        )
    ```

10. Post `SECreateConnectionParams` and receive authorization url (`connect_url`), using `SEConnectionManagerV2.createConnection` method.
    - parameters:
      - `url`: the url, which will be use to make request.
      - `data`: `SEConnectionData`
      - `pushToken`: Unique device token, which will be used as device identifier.
      - `appLanguage`: Request header to identify preferred language.

    ```swift
        SEConnectionManagerV2.createConnection(
            by: connectionBaseUrl, // Base url of the Connection
            params: connectionData,
            pushToken: pushToken,
            appLanguage: "en",
            success: { response in
                // assign received id as connection id 
                // use received connectUrl string for openning a webView for future user authentication
            },
            failure: {
                // handle error
            }
        )
    ```

11. Pass `connectUrl` to instance of `SEWebView` *(For OAuth authentication)*.

    ```swift
        let request = URLRequest(url: connectUrl)
        seWebView.load(request)
    ```

12. After passing user authencation, webView will catch `accessToken` or `error`. Result will be returned through `SEWebViewDelegate` *(For OAuth authentication)*.

    ```swift
        func webView(_ webView: WKWebView, didReceiveCallback url: URL, accessToken: AccessToken) {
            // save accessToken to Connection model and navigate to next step
        }

        func webView(_ webView: WKWebView, didReceiveCallbackWithError error: String?) {
            // handle error
        }
    ```

13. Set `accessToken` to `Connection` and save `Connection` to persistent storage (e.g. Realm, CoreData).

That's all, now you have connection to the Bank (Service Provider).

### Remove Connection

1. Send revoke request
    - parameters:
        - `SEBaseAuthenticatedWithIdRequestData`:
          - `entityId`: the id of authorization
          - `url`: the url, which will be use to make request.
          - `connectionGuid`: the uniq guid of the connection.
          - `accessToken`: a unique token string for authenticated access to API resources.
          - `appLanguage`: request header to identify preferred language.

    ```swift
        let data = SEBaseAuthenticatedWithIdRequestData(
            url: baseUrl,
            connectionGuid: connection.guid,
            accessToken: connection.accessToken,
            appLanguage: UserDefaultsHelper.applicationLanguage,
            entityId: connection.id // The id of requested entity (authorization, connection, consent)
        )

        SEConnectionManagerV2.revokeConnection(
            data: data,
            onSuccess: { response in
                // handle success callback here
            },
            onFailure: { error in
                // handle error
            }
        )
    ```

2. Delete connections from persistent storage

3. Delete related key pairs from keychain
    ```swift
        SECryptoHelper.deleteKeyPair(with: SETagHelper.create(for: connection.guid))
    ```
### Fetch authorizations list

1. For periodically fetching of authorizations list, implement a polling service. You may use `SEPoller` which will request pending Authorizations every 3 seconds.

```swift
    var pollingTimer: SEPoller?

    func startPolling() {        
        poller = SEPoller(targetClass: self, selector: #selector(getEncryptedAuthorizations))
        getEncryptedAuthorizations()
        poller?.startPolling()
    }
```

To stop polling, just invalidate timer and set it to nil:

```swift
    func stopPolling() {
        poller?.stopPolling()
        poller = nil
    }
```

2. Send request
    - parameters:
      - `SEBaseAuthenticatedRequestData`:
        - `url`: the url, which will be use to make request.
        - `connectionGuid`: the uniq guid of the connection.
        - `accessToken`: a unique token string for authenticated access to API resources.
        - `appLanguage`: request header to identify preferred language.

    ```swift
        SEAuthorizationManagerV2.getEncryptedAuthorizations(
            data: SEBaseAuthenticatedRequestData(
                url: baseUrl,
                connectionGuid: connection.guid,
                accessToken: accessToken,
                appLanguage: UserDefaultsHelper.applicationLanguage
            ),
            onSuccess: { response in
                // handle encrypted authorizations response
            },
            onFailure: { error in
                // handle error
            }
        )
    ```

3. Decrypt authorization response, using `SECryptoHelper.decrypt` method.
    - parameters:
      - `SEEncryptedData`:
        - `iv`: an initialization vector of encryption algorithm, this string is encrypted with public key linked to mobile client.
        - `key`: an secure key of encryption algorithm, this string is encrypted with public key linked to mobile client.
        - `data`: encrypted authorization payload with algorithm.
        - `algorithm`: encryption algorithm and block mode type.
        - `connectionId`: unique ID of connection
    
    ```swift
        let decryptedData = try SECryptoHelper.decrypt(encryptedData, tag: SETagHelper.create(for: connection.guid))

        guard let decryptedDictionary = decryptedData.json else { return nil }

        return SEAuthorizationDataV2(decryptedDictionary)
    ```

3. Show decrypted Authorizations to user

### Fetch authorization by ID

1. Send request
    - parameters:
      - `SEBaseAuthenticatedWithIdRequestData`:
        - `entityId`: the id of authorization
        - `url`: the url, which will be use to make request.
        - `connectionGuid`: the uniq guid of the connection.
        - `accessToken`: a unique token string for authenticated access to API resources.
        - `appLanguage`: request header to identify preferred language.

    ```swift
        SEAuthorizationManagerV2.getEncryptedAuthorization(
            data: authorizationData,
            onSuccess: { response in
                // handle SEEncryptedAuthorizationResponse
            },
            onFailure: { error in
                // handle error
            }
        )
    ```

2. Decrypt authorization response, using `SECryptoHelper.decrypt` method.
    - parameters:
      - `SEEncryptedData`:
        - `iv`: an initialization vector of encryption algorithm, this string is encrypted with public key linked to mobile client.
        - `key`: an secure key of encryption algorithm, this string is encrypted with public key linked to mobile client.
        - `data`: encrypted authorization payload with algorithm.
        - `algorithm`: encryption algorithm and block mode type.
        - `connectionId`: unique ID of connection
    
    ```swift
        let decryptedData = try SECryptoHelper.decrypt(encryptedData, tag: SETagHelper.create(for: connection.guid))

        guard let decryptedDictionary = decryptedData.json else { return nil }

        return SEAuthorizationData(decryptedDictionary)
    ```

3. Show decrypted Authorization to user

### Confirm authorization

User can confirm authorization
- parameters:
    - `SEConfirmAuthorizationRequestData`:
        - `authorizationId`: the uniq id of authorization to confirm
        - `url`: the url, which will be use to make request.
        - `connectionGuid`: the uniq guid of the connection.
        - `accessToken`: a unique token string for authenticated access to API resources.
        - `appLanguage`: request header to identify preferred language.
        - `authorizationCode`: Optional. Generated unique code per each authorization action based on set of input information (datetime, amount, payee, account, etc.)

```swift
    SEAuthorizationManagerV2.confirmAuthorization(
        data: confirmAuthData,
        onSuccess: { response in
            // handle success here
        },
        onFailure: { error in
            // handle error
        }
    )
```

### Deny authorization  

User can deny authorization
- parameters:
    - `SEConfirmAuthorizationRequestData`:
        - `url`: the url, which will be used to make request.
        - `connectionGuid`: the uniq guid of the connection.
        - `accessToken`: a unique token string for authenticated access to API resources.
        - `appLanguage`: Request header to identify preferred language.
        - `authorizationId`: the uniq id of authorization to confirm
        - `authorizationCode`: Optional.

```swift
    SEAuthorizationManagerV2.denyAuthorization(
        data: denyAuthData,
        onSuccess: { response in
            // handle success here
        },
        onFailure: { error in
            // handle error
        }
    )
```

### Send Instant Action

Instant Action feature is designated to authenticate an action of Service Provider (e.g. Sign-In, Payment Order). Each Instant Action has unique code `actionGuid`. After receiving of `actionGuid`, Authenticator app should submit to selected by user Connection:

- parameters:
    - `SEActionRequestDataV2`:
        - `url`: the url, which will be used to make request.
        - `actionId`: the unique identifier of the action.
        - `providerId`: the unique identifier of the provider.
        - `connectionId`: the unique identifier of the Connection where action will be submitted.
        - `accessToken`: a unique token string for authenticated access to API resources.
        - `appLanguage`: Request header to identify preferred language.

```swift
    let actionData = SEActionRequestDataV2(
        url: connectUrl,
        connectionId: connection.id,
        accessToken: connection.accessToken,
        appLanguage: UserDefaultsHelper.applicationLanguage,
        providerId: providerId,
        actionId: actionId,
    )

    SEActionManagerV2.submitAction(
        data: actionData,
        onSuccess: { response in
            // handle success here
        },
        onFailure: { error in
            // handle error
        }
    )
```

On success, Authenticator app receives `SESubmitActionResponseV2` which has optional fields `connectionId` and `authorizationId` (if additional confirmation is required).

### Get User Consents

1. Send request
    - parameters:
      - `SEBaseAuthenticatedRequestData`:
        - `url`: the url, which will be use to make request.
        - `connectionGuid`: the uniq guid of the connection.
        - `accessToken`: a unique token string for authenticated access to API resources.
        - `appLanguage`: request header to identify preferred language.

    ```swift
        SEConsentManagerV2.getEncryptedConsents(
            data: SEBaseAuthenticatedRequestData(
                url: baseUrl,
                connectionGuid: connection.guid,
                accessToken: accessToken,
                appLanguage: UserDefaultsHelper.applicationLanguage
            ),
            onSuccess: { response in
                // handle encrypted consents response
            },
            onFailure: { error in
                // handle error
            }
        )
    ```

2. Decrypt authorization response, using `SECryptoHelper.decrypt` method.
    - parameters:
      - `SEEncryptedData`:
        - `iv`: an initialization vector of encryption algorithm, this string is encrypted with public key linked to mobile client.
        - `key`: an secure key of encryption algorithm, this string is encrypted with public key linked to mobile client.
        - `data`: encrypted Consent object.
        - `algorithm`: encryption algorithm and block mode type.
        - `connectionId`: unique ID of connection
    
    ```swift
        let decryptedData = try SECryptoHelper.decrypt(encryptedData, tag: SETagHelper.create(for: connection.guid))

        guard let decryptedDictionary = decryptedData.json else { return nil }

        return SEConsentData(decryptedDictionary)
    ```

3. Show decrypted Consents to user

### Revoke Consent

1. Send revoke request
    - parameters:
      - `SEBaseAuthenticatedWithIdRequestData`:
        - `entityId`: the id of authorization
        - `url`: the url, which will be use to make request.
        - `connectionGuid`: the uniq guid of the connection.
        - `accessToken`: a unique token string for authenticated access to API resources.
        - `appLanguage`: request header to identify preferred language.

    ```swift
        SEAuthorizationManagerV2.revokeConsent(
            data: authorizationData,
            onSuccess: { response in
                // handle success result
            },
            onFailure: { error in
                // handle error
            }
        )
    ```

---
Copyright © 2022 Salt Edge. https://www.saltedge.com 
