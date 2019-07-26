//
//  TabBarDataSource.swift
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

enum TabBarControllerType: Int {
    case authorizations = 0
    case connections = 1
    case settings = 2
}

struct TabBarDataSource {
    static func tabBarItem(for type: TabBarControllerType) -> UITabBarItem {
        var item: UITabBarItem

        switch type {
        case .authorizations:
            item = UITabBarItem(
                title: "",
                image: #imageLiteral(resourceName: "authorizations").withRenderingMode(.alwaysOriginal),
                selectedImage: #imageLiteral(resourceName: "authorizations_selected").withRenderingMode(.alwaysOriginal)
            )
        case .connections:
            item = UITabBarItem(
                title: "",
                image: #imageLiteral(resourceName: "bank").withRenderingMode(.alwaysOriginal),
                selectedImage: #imageLiteral(resourceName: "bank_selected").withRenderingMode(.alwaysOriginal)
            )
        case .settings:
            item = UITabBarItem(
                title: "",
                image: #imageLiteral(resourceName: "settings").withRenderingMode(.alwaysOriginal),
                selectedImage: #imageLiteral(resourceName: "settings_selected").withRenderingMode(.alwaysOriginal)
            )
        }

        item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        return item
    }
}
