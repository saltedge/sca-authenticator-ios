//
//  LabelExtensions.swift
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

extension UILabel {
    convenience init(font: UIFont, alignment: NSTextAlignment = .center, textColor: UIColor = .titleColor) {
        self.init()
        self.font = font
        self.textColor = textColor
        self.textAlignment = alignment
        self.numberOfLines = 0
    }

    static var titleLabel: UILabel {
        let label = UILabel()
        label.font = .auth_19regular
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    static var descriptionLabel: CustomSpacingLabel {
        let label = CustomSpacingLabel()
        label.font = .auth_15regular
        label.textColor = .auth_darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }
}
