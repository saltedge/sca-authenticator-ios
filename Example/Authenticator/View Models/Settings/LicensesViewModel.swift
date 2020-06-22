//
//  LicensesViewModel.swift
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2020 Salt Edge Inc.
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

import UIKit

protocol LicensesEventsDelegate: class {
    func licenceSelected(with urlString: String, title: String)
}

final class LicensesViewModel {
    typealias Library = (String, String)

    private let items: [Library] = {
        return [("ReachabilitySwift", "https://raw.githubusercontent.com/ashleymills/Reachability.swift/master/LICENSE"),
                ("TinyConstraints", "https://raw.githubusercontent.com/roberthein/TinyConstraints/master/LICENSE"),
                ("SDWebImage", "https://raw.githubusercontent.com/SDWebImage/SDWebImage/master/LICENSE"),
                ("Realm Swift", "https://raw.githubusercontent.com/realm/realm-cocoa/master/LICENSE"),
                ("Square/Valet", "https://raw.githubusercontent.com/square/Valet/master/LICENSE"),
                ("Typist", "https://raw.githubusercontent.com/totocaster/Typist/master/LICENSE"),
                ("Firebase", "https://firebase.google.com/terms"),
                ("SwiftyAttributes", "https://raw.githubusercontent.com/eddiekaiger/SwiftyAttributes/master/LICENSE"),
                ("Quick/Nimble", "https://raw.githubusercontent.com/Quick/Quick/master/LICENSE"),
                ("CryptoSwift", "https://raw.githubusercontent.com/krzyzanowskim/CryptoSwift/master/LICENSE")]
    }()

    weak var delegate: LicensesEventsDelegate?

    var sections: Int {
        return 1
    }

    func rows(for section: Int) -> Int {
        return items.count
    }

    func item(for indexPath: IndexPath) -> Library {
        return items[indexPath.row]
    }

    func cellTitle(for indexPath: IndexPath) -> String {
        return item(for: indexPath).0
    }

    func selected(indexPath: IndexPath) {
        delegate?.licenceSelected(with: item(for: indexPath).1, title: cellTitle(for: indexPath))
    }
}
