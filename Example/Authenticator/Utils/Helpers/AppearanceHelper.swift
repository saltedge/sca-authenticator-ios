//
//  AppearanceHelper.swift
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

import UIKit

struct AppearanceHelper {
    static func setup() {
        let navBarAppearance = UINavigationBar.appearance()

        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.titleColor]
            appearance.backgroundColor = .backgroundColor
            navBarAppearance.standardAppearance = appearance
            navBarAppearance.scrollEdgeAppearance = appearance
        }

        navBarAppearance.barStyle = .default
        navBarAppearance.backgroundColor = .backgroundColor
        navBarAppearance.barTintColor = .backgroundColor
        navBarAppearance.tintColor = .lightBlue
        navBarAppearance.isTranslucent = false
        navBarAppearance.shadowImage = UIImage()
        navBarAppearance.prefersLargeTitles = true
        navBarAppearance.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.titleColor,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 30)
        ]
    }
}
