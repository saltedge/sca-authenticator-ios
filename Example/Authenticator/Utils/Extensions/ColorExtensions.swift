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

    static var secondaryButtonColor: UIColor {
        return UIColor(named: "secondaryButtonColor", in: .authenticator_main, compatibleWith: nil)!
    }

    static var selectedColor: UIColor {
        return UIColor(named: "selectedColor", in: .authenticator_main, compatibleWith: nil)!
    }

    static var backgroundColor: UIColor! {
        return UIColor(named: "background", in: .authenticator_main, compatibleWith: nil)!
    }

    static var textColor: UIColor {
        return UIColor(named: "textColor", in: .authenticator_main, compatibleWith: nil)!
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

    static var auth_lightGray50: UIColor {
        return UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 0.5)
    }

    static var auth_gray: UIColor {
        return UIColor(red: 158.0/255.0, green: 158.0/255.0, blue: 158.0/255.0, alpha: 1.0)
    }

    static var auth_darkGray: UIColor {
        return UIColor(red: 33.0/255.0, green: 33.0/255.0, blue: 33.0/255.0, alpha: 1.0)
    }

    static var auth_blue20: UIColor {
        return UIColor(red: 67.0/255.0, green: 84.0/255.0, blue: 179.0/255.0, alpha: 0.2)
    }

    static var auth_blue: UIColor {
        return UIColor(red: 67.0/255.0, green: 84.0/255.0, blue: 179.0/255.0, alpha: 1.0)
    }

    static var auth_darkBlue: UIColor {
        return UIColor(red: 53.0/255.0, green: 55.0/255.0, blue: 69.0/255.0, alpha: 1.0)
    }

    static var auth_cyan: UIColor {
        return UIColor(red: 133.0/255.0, green: 205.0/255.0, blue: 207.0/255.0, alpha: 1.0)
    }

    static var auth_lightCyan: UIColor {
        return UIColor(red: 229.0/255.0, green: 249.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    }

    static var auth_backgroundColor: UIColor {
        return UIColor(red: 244.0/255.0, green: 244.0/255.0, blue: 246.0/255.0, alpha: 1.0)
    }

    static var auth_red: UIColor {
        return UIColor(red: 254.0/255.0, green: 95.0/255.0, blue: 85.0/255.0, alpha: 1.0)
    }

    static var auth_yellow: UIColor {
        return UIColor(red: 252.0/255.0, green: 172.0/255.0, blue: 15.0/255.0, alpha: 1.0)
    }

    static var auth_green: UIColor {
        return UIColor(red: 0.0, green: 189.0/255.0, blue: 129.0/255.0, alpha: 1.0)
    }
}
