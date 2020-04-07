# Authenticator iOS SDK  

Authenticator iOS SDK - is a module for connecting to Salt Edge Authenticator API of Bank (Service Provider) System, that implements
Strong Customer Authentication/Dynamic Linking process.  

You can find source code of Authenticator Identity Service here: for [Authenticator Identity Service iOS](https://github.com/saltedge/sca-identity-service-example).

## How Authenticator system works

Read Wiki docs about [Authenticator Identity Service](https://github.com/saltedge/sca-identity-service-example/wiki) API and workflow.

## Requirements

- iOS 10.0+
- Xcode 10.2+
- Swift 5+

## Installation

### CocoaPods

CocoaPods is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website.
To integrate `SaltedgeAuthenticatorSDK` into your Xcode project using CocoaPods, specify it in your Podfile:

`pod 'SaltedgeAuthenticatorSDK'`

## How to use

Authenticator SDK provide next features:
* [Create connection (Link Bank flow)](#create-connection)
* [Remove connection (Remove Bank)](#remove-connection)
* [Fetch authorizations list](#fetch-authorizations-list)
* [Fetch authorization by ID](#fetch-authorization-by-id)
* [Confirm authorization](#confirm-authorization)
* [Deny authorization](#deny-authorization)
* [Send instant action](#send-instant-action)

### Data models

#### Connection model
 * `guid` **[string]** - Alias to RSA keypair
 * `id` **[string]** - Unique id received from Authenticator API
 * `name` **[string]** - Provider's name from `SEProviderResponse`
 * `code` **[string]** - Provider's code
 * `logoUrl` **[string]** - Provider's logo url. May be empty
 * `connectUrl` **[string]** - Base url of Authenticator API
 * `accessToken` **[string]** - Access token for accessing Authenticator API resources
 * `status` **[string]** - Connection Status. ACTIVE or INACTIVE

### SEEncryptedData
 * `iv` **[string]** - an initialization vector of encryption algorithm, this string is encrypted with public key linked to mobile client
 * `key` **[string]** - an secure key of encryption algorithm, this string is encrypted with public key linked to mobile client
 * `data` **[string]** - encrypted authorization payload with algorithm mentioned above

#### SEEncryptedAuthorizationResponse
 * `connection_id` **[string]** - Optional. A unique ID of Mobile Client (Service Connection). Used to decrypt models in the mobile application
 * `iv` **[string]** - an initialization vector of encryption algorithm, this string is encrypted with public key linked to mobile client
 * `key` **[string]** - an secure key of encryption algorithm, this string is encrypted with public key linked to mobile client
 * `algorithm` **[string]** - encryption algorithm and block mode type
 * `data` **[string]** - encrypted authorization payload with algorithm mentioned above

#### SEDecryptedAuthorizationData
 * `id` **[string]** - a unique id of authorization action
 * `connection_id` **[string]** - a unique ID of Connection. Used to decrypt models in the mobile application
 * `title` **[string]** - a human-readable title of authorization action
 * `description` **[string]** - a human-readable description of authorization action
 * `authorization_code` **[string]** - Optional. A unique code for each operation (e.g. payment transaction), specific to the attributes of operation, must be used once
 * `created_at` **[datetime]** - time when the authorization was created
 * `expires_at` **[datetime]** - time when the authorization should expire

### Responses

##### SEProviderResponse
 * `name` **[string]** - Provider's name
 * `code` **[string]** - Provider's code
 * `logoUrl` **[string]** - Optional. Provider's logo url.
 * `connectUrl` **[string]** - Base url of Authenticator API

##### SECreateConnectionResponse
 * `connect_url` ***[string]** - an url of Connect Web Page for future end-user authentication
 * `id` ***[string]*** - an ID of current connection

##### SEConfirmAuthorizationResponse
 * `id` **[string]** - a unique id of authorization
 * `success` **[boolean]** - result of action

##### SERevokeConnectionResponse
 * `success` **[boolean]** - result of action

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
        SEProviderManager.fetchProviderData(
            url: configurationUrl,
            onSuccess: { response in
                // handle SEProviderResponse
            },
            onFailure: { error in
                // handle error
            }
        )
    ```

5. Create `SEConnectionData` model, where will be created keypair using `tag`.
    - parameters:
      - `code`: The code of the provider
      - `tag`: The tag, which will be used for creating keypair

    ```swift
        let connectionData = SEConnectionData(code: providerCode, tag: connectionGuid)
    ```

6. Post `SEConnectionData` and receive authorization url (`connect_url`), using `SEConnectionManager.getConnectUrl` method.
    - parameters:
      - `url`: the url, which will be use to make request.
      - `data`: `SEConnectionData`
      - `pushToken`: Unique device token, which will be used as device identifier.
      - `appLanguage`: Request header to identify preferred language.

    ```swift
        SEConnectionManager.getConnectUrl(
            by: connectionUrl,
            data: connectionData,
            pushToken: pushToken,
            appLanguage: "en",
            success: { response in
                // assign received id as connection id 
                // use received connectUrl string for openning webView for future user authentication
            },
            failure: {
                // handle error
            }
        )
    ```

7. Pass `connectUrl` to instance of `SEWebView`.

    ```swift
        let request = URLRequest(url: connectUrl)
        seWebView.load(request)
    ```

8. After passing user authencation, webView will catch `accessToken` or `error`. Result will be returned through `SEWebViewDelegate`.

    ```swift
        func webView(_ webView: WKWebView, didReceiveCallback url: URL, accessToken: AccessToken) {
            // save accessToken to Connection model and navigate to next step
        }

        func webView(_ webView: WKWebView, didReceiveCallbackWithError error: String?) {
            // handle error
        }
    ```

9. Set `accessToken` to `Connection` and save `Connection` to persistent storage (e.g. Realm, CoreData).

That's all, now you have connection to the Bank (Service Provider).

### Remove Connection

1. Send revoke request
    - parameters:
      - `url`: the url, which will be use to make request.
      - `data`: `SERevokeConnectionData`
      - `appLanguage`: Request header to identify preferred language.

    ```swift
        SEConnectionManager.revokeConnection(
            by: url,
            data: revokeConnectionData,
            appLanguage: "language",
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

1. For periodically fetching of authorizations list, implement polling service. You may use Swift Timer which will request pending Authorizations every 3 seconds.

```swift
    var pollingTimer: Timer?

    func startPolling() {
        getEncryptedAuthorizations()
        
        pollingTimer = Timer.scheduledTimer(
            timeInterval: 3.0,
            target: self,
            selector: #selector(getEncryptedAuthorizations),
            userInfo: nil,
            repeats: true
        )
    }
```

To stop polling, just invalidate timer and set it to nil:

```swift
    func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
```

2. Send request
    - parameters:
      - `SEBaseAuthorizationData`:
        - `url`: the url, which will be use to make request.
        - `connectionGuid`: the uniq guid of the connection.
        - `accessToken`: a unique token string for authenticated access to API resources.
        - `appLanguage`: request header to identify preferred language.

    ```swift
        SEAuthorizationManager.getEncryptedAuthorizations(
            data: baseAuthorizationData,
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
    
    ```swift
        let encryptedData = SEEncryptedData(data: response.data, key: response.key, iv: response.iv)
        let decryptedData = try SECryptoHelper.decrypt(encryptedData, tag: SETagHelper.create(for: connection.guid))

        guard let decryptedDictionary = decryptedData.json else { return nil }

        return SEDecryptedAuthorizationData(decryptedDictionary)
    ```

3. Show decrypted Authorizations to user

### Fetch authorization by ID

1. Send request
    - parameters:
      - `SEAuthorizationData`:
        - `authorizationId`: the id of authorization
        - `url`: the url, which will be use to make request.
        - `connectionGuid`: the uniq guid of the connection.
        - `accessToken`: a unique token string for authenticated access to API resources.
        - `appLanguage`: request header to identify preferred language.

    ```swift
        SEAuthorizationManager.getEncryptedAuthorization(
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
    
    ```swift
        let encryptedData = SEEncryptedData(data: response.data, key: response.key, iv: response.iv)
        let decryptedData = try SECryptoHelper.decrypt(encryptedData, tag: SETagHelper.create(for: connection.guid))

        guard let decryptedDictionary = decryptedData.json else { return nil }

        return SEDecryptedAuthorizationData(decryptedDictionary)
    ```

3. Show decrypted Authorization to user

### Confirm authorization

User can confirm authorization
- parameters:
    - `SEConfirmAuthorizationData`:
        - `authorizationId`: the uniq id of authorization to confirm
        - `url`: the url, which will be use to make request.
        - `connectionGuid`: the uniq guid of the connection.
        - `accessToken`: a unique token string for authenticated access to API resources.
        - `appLanguage`: request header to identify preferred language.
        - `authorizationCode`: Optional. Generated unique code per each authorization action based on set of input information (datetime, amount, payee, account, etc.)

```swift
    SEAuthorizationManager.confirmAuthorization(
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
    - `SEConfirmAuthorizationData`:
        - `authorizationId`: the uniq id of authorization to confirm
        - `url`: the url, which will be used to make request.
        - `connectionGuid`: the uniq guid of the connection.
        - `accessToken`: a unique token string for authenticated access to API resources.
        - `appLanguage`: Request header to identify preferred language.
        - `authorizationCode`: Optional.

```swift
    SEAuthorizationManager.denyAuthorization(
        data: confirmAuthData,
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
    - `SEActionData`:
        - `url`: the url, which will be used to make request.
        - `guid`: the unique identifier af an action.
        - `connectionGuid`: the unique identifier af the Connection where action will be submitted.
        - `accessToken`: a unique token string for authenticated access to API resources.
        - `appLanguage`: Request header to identify preferred language.

```swift
    let actionData = SEActionData(
        url: connectUrl,
        guid: actionGuid,
        connectionGuid: connection.guid,
        accessToken: connection.accessToken,
        appLanguage: UserDefaultsHelper.applicationLanguage
    )

    SEActionManager.submitAction(
        data: actionData,
        onSuccess: { response in
            // handle success here
        },
        onFailure: { error in
            // handle error
        }
    )
```

On success, Authenticator app receives `SESubmitActionResponse` which has optional fields `connectionId` and `authorizationId` (if additional confirmation is required).
