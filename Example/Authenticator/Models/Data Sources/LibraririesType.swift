//
//  LibraririesType
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

enum LibraririesType: String, CaseIterable {
    case reachability
    case tinyConstraints
    case sdWebImage
    case realm
    case valet
    case typist
    case crashlytics
    case firebase
    case swiftyAttributes
    case quick
    case cryptoSwift

    var item: (String, String) {
        switch self {
        case .reachability:
            return ("ReachabilitySwift", "https://raw.githubusercontent.com/ashleymills/Reachability.swift/master/LICENSE")
        case .tinyConstraints: return ("TinyConstraints", "https://raw.githubusercontent.com/roberthein/TinyConstraints/master/LICENSE")
        case .sdWebImage: return ("SDWebImage", "https://raw.githubusercontent.com/SDWebImage/SDWebImage/master/LICENSE")
        case .realm: return ("Realm Swift", "https://raw.githubusercontent.com/realm/realm-cocoa/master/LICENSE")
        case .valet: return ("Square/Valet", "https://raw.githubusercontent.com/square/Valet/master/LICENSE")
        case .typist: return ("Typist", "https://raw.githubusercontent.com/totocaster/Typist/master/LICENSE")
        case .crashlytics:
            return (
                "Crashlytics",
                "https://firebase.google.com/products/crashlytics?utm_source=crashlytics_marketing&utm_medium=redirect&utm_campaign=crashlytics_redirect"
            )
        case .firebase: return ("Firebase", "https://firebase.google.com/terms")
        case .swiftyAttributes: return ("SwiftyAttributes", "https://raw.githubusercontent.com/eddiekaiger/SwiftyAttributes/master/LICENSE")
        case .quick: return ("Quick/Nimble", "https://raw.githubusercontent.com/Quick/Quick/master/LICENSE")
        case .cryptoSwift: return ("CryptoSwift", "https://raw.githubusercontent.com/krzyzanowskim/CryptoSwift/master/LICENSE")
        }
    }
}
