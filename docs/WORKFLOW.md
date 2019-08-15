# Salt Edge Authenticator iOS Application Workflow

## Current application consist of 2 main modules:  
* SDK pod - responsible to interaction between presentation layer (App module) and Identity Service. Available on CocoaPods.
* EXAMPLE - responsible to interaction between end-user and SDK module and implementing base flows logic.

## General Requirements for Authenticator application
* Without explicit need not to store sensitive data
* Stored sensitive data should be encrypted
* Asymmetric keys should be stored in the system protected area (e.g. Keystore)
* Access to application should be blocked by pin input or fingerprint input
* Action confirmation should be done by fingerprint input or pin input

## Read before: 
* [Authenticator Identity Service API](https://github.com/saltedge/sca-identity-service-example/blob/master/docs/IDENTITY_SERVICE_API.md)
* [Authenticator Identity Service Wiki](https://github.com/saltedge/sca-identity-service-example/wiki)

## Connect Bank (Service Provider)
[![Authenticator_Enrollment_-_Sequence_Diagram](https://github.com/saltedge/sca-identity-service-example/blob/master/docs/images/enrollment-sequence-diagram.svg)](https://github.com/saltedge/sca-identity-service-example/blob/master/docs/images/enrollment-sequence-diagram.svg)

**Click on IMAGE to enlarge the Sequence Diagram.**
  
1. User scans QR code
2. Parse QR code and extract deep-link with provider's `configuration url`
3. Fetch provider configuration from `configuration url`
```
{
  "data": {
    "connect_url": "https://connector.bank_url.com",
    "code": "demobank",
    "name": "Demobank",
    "logo_url": "https://connector.bank_url.com/assets/logo.png",
    "support_email": "support@example.com",
    "version": "1"
  }
}
```

4. Create Connection model and RSA key-pair in Keystore
5. Send initial data to [connect](authenticator/Identity-Service#connect-to-service-provider)
```
{
  "data": {
    "public_key": "-----BEGIN PUBLIC KEY-----\nMIGfMAGCSqGSIAB\n-----END PUBLIC KEY-----\n",
    "return_url": "authenticator://oauth/redirect",
    "platform": "ios",
    "push_token": "e886d1a84cfa3cd5343b70a3f9971758e"
  }
}
```
6. Receive `connect_url` for future authentication
7. Show authentication `connect_url` in WebView and wait for redirect which starts with `return_url`
8. Parse `return_url` and add `access_token` to `Connection` if exist or otherwise get error and show it to user
9. Save `Connection`
10. Show connections list with new `Connection`  

## Confirm Authorization  

[![Authenticator_Strong_Authentication_-_Sequence_Diagram](https://github.com/saltedge/sca-identity-service-example/blob/master/docs/images/strong-authentication-sequence-diagram.svg)](https://github.com/saltedge/sca-identity-service-example/blob/master/docs/images/strong-authentication-sequence-diagram.svg)

**Click on IMAGE to enlarge the Sequence Diagram.**
 
### Confirm Authorization from Push notification
1. Receive push notification 
2. User click on push notification
3. Run the application and ask fingerprint/pin input to unlock app.
4. Show Authorization Details 
5. Run poll [Authorization data](authenticator/Identity-Service#show-authorization) by `connection_id` and `authorization_id` from push notification 
6. Decrypt received response and update view content.
7. If user click `Confirm/Deny` send [Confirm/Deny](authenticator/Identity-Service#confirm-authorization) request.
8. If received success response close screen and application

### Confirm Authorization from Authorizations list
1. Open Authorizations list screen
2. Poll [Authorizations list](authenticator/Identity-Service#show-authorizations-list)
3. Decrypt received response and show list of available (not expired) authorizations
4. If user click `Confirm/Deny` send [Confirm/Deny](authenticator/Identity-Service#confirm-authorization) request. If user click `Confirm` ask before sending request, fingerprint/pin confirmation.
5. If received success response remove corresponding list item.

## Database Models  

### Connection
- `id` - a unique identifier received from server-side
- `guid` - generated unique identifier (i.e. 128-bit UUID). Alias (Tag) of asymmetric keys in KeyStore
- `name` - the name of the Service Provider
- `code` - the code of the Service Provider
- `connect_url` - a base URL of Service Provider API from QR code. Used as prefix for all network connections
- `logo_url`- the logo asset url of the Service Provider
- `access_token` - a unique token string for authenticated access to API resources
- `status` - connection status (`ACTIVE` or `INACTIVE`)
- `created_at` - a model creation datetime
- `updated_at` - a model update datetime 
