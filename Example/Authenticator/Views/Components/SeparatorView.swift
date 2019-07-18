//
//  SeparatorView.swift
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
import TinyConstraints

class SeparatorView: UIView {
    static var defaultThickness: CGFloat {
        return 1.0 / UIScreen.main.scale
    }

    private var axis: NSLayoutConstraint.Axis = .horizontal
    private var thickness: CGFloat = SeparatorView.defaultThickness

    convenience init(axis: NSLayoutConstraint.Axis = .horizontal,
                     thickness: CGFloat = SeparatorView.defaultThickness) {
        self.init(frame: .zero)
        self.axis = axis
        self.thickness = thickness
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        _ = axis == .vertical ? width(thickness) : height(thickness)
    }
}
