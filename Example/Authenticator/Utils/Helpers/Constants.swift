//
//  Constants.swift
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

func after(_ time: Double, _ doBlock: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(
        deadline: .now() + time,
        execute: {
            doBlock()
        }
    )
}

struct AnimationConstants {
    static let defaultDuration: CGFloat = 0.4
    static let defaultVelocity: CGFloat = 0.2
}

struct AppLayout {
    static let sideOffset: CGFloat = 30.0
    static let cellSeparatorOffset: CGFloat = 47.0
    static let pickersLeftOffset: CGFloat = 50.0
    static let cellDefaultHeight: CGFloat = 48.0
    static let loadingIndicatorSize: CGSize = CGSize(width: 80.0, height: 80.0)
    static let screenWidth: CGFloat = UIScreen.main.bounds.width
    static let screenHeight: CGFloat = UIScreen.main.bounds.height
}
