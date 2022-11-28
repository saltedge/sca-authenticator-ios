[![Build Status](https://travis-ci.org/saltedge/sca-authenticator-ios.svg?branch=master)](https://travis-ci.org/saltedge/sca-authenticator-ios)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SaltedgeAuthenticatorSDK.svg?style=flat)](https://img.shields.io/cocoapods/v/SaltedgeAuthenticatorSDK.svg?style=flat)
[![GPLv3 license](https://img.shields.io/badge/License-GPLv3-blue.svg)](http://perso.crans.org/besson/LICENSE.html)
[![Gitter](https://badges.gitter.im/Salt-Edge/authenticator.svg)](https://gitter.im/Salt-Edge/authenticator?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/fold_left.svg?style=social&label=Follow%20%40saltedge)](http://twitter.com/saltedge)

<br />
<p align="center">
  <img src="docs/authenticator_ios_logo.png" alt="Logo" width="80" height="80">
  <h3 align="center">
    <a href="https://www.saltedge.com/products/strong_customer_authentication">
    Salt Edge Authenticator App - Strong Customer Authentication Solution
    </a>
  </h3>
  <p align="center">
    <br />
    <a href="https://github.com/saltedge/sca-identity-service-example/wiki"><strong>Explore our Wiki »</strong></a>
    <br />
    <br />
  </p>
</p>


# Salt Edge Authenticator iOS Client  

Salt Edge Authenticator iOS Client - is a mobile client of Authenticator API of Bank (Service Provider) System system that implements Strong Customer Authentication/Dynamic Linking process.  
The purpose of Authenticator iOS Client is to add possibility to authorize required actions for end-user.  

You can download mobile application:   
<a href='https://apps.apple.com/md/app/priora-authenticator/id1277625653'>
    <img src='https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Download_on_the_App_Store_Badge.svg/1000px-Download_on_the_App_Store_Badge.svg.png' alt='Get it on App Store' height="56px"/>
</a> 
  
## Source code

You can find related source code: 
* [Authenticator Identity Service](https://github.com/saltedge/sca-identity-service-example)
* [Authenticator Android app](https://github.com/saltedge/sca-authenticator-android).

## How it works

* ### [Authenticator iOS SDK](SaltedgeAuthenticatorSDK/README.md)
* ### [Authenticator iOS SDK v2](SaltedgeAuthenticatorSDKv2/README.md)
* ### [Authenticator iOS app workflow](docs/WORKFLOW.md)
* ### [Authenticator Identity Service Wiki](https://github.com/saltedge/sca-identity-service-example/wiki)
* ### [Authenticator Identity Service API](https://github.com/saltedge/sca-identity-service-example/blob/master/docs/IDENTITY_SERVICE_API.md)

## Prerequisites

* Xcode 12.2
* iOS 10.0+
* Swift 5+
* swiftlint
  ```bash
  brew install swiftlint
  ```
  
## SDK remote installation via [CocoaPods](https://cocoapods.org)
  
#### Add the pod to your `Podfile`
  
  ```ruby
  pod 'SaltedgeAuthenticatorSDK', '~> 1.1.1'
  ```

#### To install pods, run next command in terminal:

  `pod install`

#### Import SDK into your app

  `import SEAuthenticator`

## SDK local installation via [CocoaPods](https://cocoapods.org)

#### Copy required Salt Edge SDKs directories to your project

1. [Core module, required for both SDKs versions](https://github.com/saltedge/sca-authenticator-ios/tree/master/SaltedgeAuthenticatorCore)
2. [SDK v1](https://github.com/saltedge/sca-authenticator-ios/tree/master/SaltedgeAuthenticatorSDK)
3. [SDK v2](https://github.com/saltedge/sca-authenticator-ios/tree/master/SaltedgeAuthenticatorSDKv2)

#### Add Salt Edge SDK pods to your `Podfile`, specifying the path to SDK

  ```ruby
  pod 'SaltedgeAuthenticatorCore', :path => 'path_to_SaltedgeAuthenticatorCore'
  pod 'SaltedgeAuthenticatorSDK', :path => 'path_to_SaltedgeAuthenticatorSDK'
  pod 'SaltedgeAuthenticatorSDKv2', :path => 'path_to_SaltedgeAuthenticatorSDKv2'
  ```

#### To install pods, run next command in terminal:

  `pod install`

#### Import required SDKs into your app

  ```swift
  import SEAuthenticatorCore
  import SEAuthenticatorV2
  ```

## How to build Salt Edge Authenticator app locally

You can install app from [Apple App Store](https://apps.apple.com/md/app/priora-authenticator/id1277625653) 
or build from source code.

1. Fork this repository
1. Open terminal
1. Move to project directory `sca-authenticator-ios/Example`
1. Command in terminal: `bundle install` (To install all required gems)
1. Command in terminal: `pod install` (To install all required pods)

    If `pod install` fails on M1 Macs, do next: 
    ```
    sudo arch -x86_64 gem install ffi
    arch -x86_64 pod update
    ```
    Also make sure you set the `arm64` values in the "Build Settings" -> "Architectures" -> "Excluded Architectures". 
1. Open project's workspace file in Xcode (`Example/Authenticator.xcworkspace`)
1. Create `application.plist` configuration file using `application.example.plist`
1. If you have intent to use Firebase Crashlytics then generate `GoogleService-info.plist` and add it to project.
1. Build and run application on target device or simulator

## Contribute

In the spirit of [free software][free-sw], **everyone** is encouraged to help [improve this project](CONTRIBUTING.md).

* [Contributing Rules](CONTRIBUTING.md)  

[free-sw]: http://www.fsf.org/licensing/essays/free-sw.html

## Contact us

Feel free to [contact us](https://www.saltedge.com/pages/contact_support)

## License

**Salt Edge Authenticator (SCA solution) is multi-licensed, and can be used and distributed:**  
- under a GNU GPLv3 license for free (open source). See the [LICENSE](LICENSE.txt) file.
- under a proprietary (commercial) license, to be used in closed source applications. 

[More information about licenses](https://github.com/saltedge/sca-identity-service-example/wiki/Multi-license).  

**Additional permission under GNU GPL version 3 section 7**   
If you modify this Program, or any covered work, by linking or combining it with [THIRD PARTY LIBRARY](THIRD_PARTY_NOTICES.md) (or a modified version of that library), containing parts covered by the [TERMS OF LIBRARY's LICENSE](THIRD_PARTY_NOTICES.md), the licensors of this Program grant you additional permission to convey the resulting work. {Corresponding Source for a non-source form of such a combination shall include the source code for the parts of [LIBRARY](THIRD_PARTY_NOTICES.md) used as well as that of the covered work.}  
  
**AppStore Legal Notice**  
[APP_STORE_NOTICE](docs/APP_STORE_NOTICE.md)  

___
Copyright © 2019 Salt Edge. https://www.saltedge.com 
