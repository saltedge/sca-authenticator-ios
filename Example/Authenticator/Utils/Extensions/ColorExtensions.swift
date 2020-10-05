//
//  ColorExtensions.swift
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

extension UIColor {
    static var actionColor: UIColor {
        return UIColor(named: "actionColor", in: .authenticator_main, compatibleWith: nil)!
    }

    static var secondaryBackground: UIColor {
        return UIColor(named: "secondaryBackground", in: .authenticator_main, compatibleWith: nil)!
    }

    static var selectedColor: UIColor {
        return UIColor(named: "selectedColor", in: .authenticator_main, compatibleWith: nil)!
    }

    static var backgroundColor: UIColor! {
        return UIColor(named: "background", in: .authenticator_main, compatibleWith: nil)!
    }

    static var lightBlue: UIColor {
        return UIColor(named: "lightBlue", in: .authenticator_main, compatibleWith: nil)!
    }

    static var darkBlue: UIColor {
        return UIColor(named: "darkBlue", in: .authenticator_main, compatibleWith: nil)!
    }

    static var lightGray: UIColor {
        return UIColor(named: "lightGray", in: .authenticator_main, compatibleWith: nil)!
    }

    static var extraLightGray: UIColor {
        return UIColor(named: "extraLightGray", in: .authenticator_main, compatibleWith: nil)!
    }

    static var primaryDark: UIColor {
        return UIColor(named: "primaryDark", in: .authenticator_main, compatibleWith: nil)!
    }

    static var titleColor: UIColor {
        return UIColor(named: "titleColor", in: .authenticator_main, compatibleWith: nil)!
    }

    static var dark60: UIColor {
        return UIColor(named: "dark60", in: .authenticator_main, compatibleWith: nil)!
    }

    static var dark80_grey100: UIColor {
        return UIColor(named: "dark80_grey100", in: .authenticator_main, compatibleWith: nil)!
    }

    static var white_dark100: UIColor {
        return UIColor(named: "white_dark100", in: .authenticator_main, compatibleWith: nil)!
    }

    static var extraLightGray_blueBlack: UIColor {
        return UIColor(named: "extraLightGray_blueBlack", in: .authenticator_main, compatibleWith: nil)!
    }

    static var redAlert: UIColor {
        return UIColor(named: "redAlert", in: .authenticator_main, compatibleWith: nil)!
    }
}
