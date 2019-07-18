//
//  ProgressBar.swift
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

final class ProgressBar: UIView {
    private let leftBar = UIView(frame: .zero)
    private var leftConstraint: Constraint?

    init() {
        super.init(frame: .zero)
        layout()
        stylize()
    }

    func update(with percentage: CGFloat) {
        guard let constraint = leftConstraint else { return }

        constraint.constant = width * percentage
        UIViewPropertyAnimator(duration: 1.0, curve: .easeOut) {
            self.layoutIfNeeded()
        }.startAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension ProgressBar: Layoutable {
    func layout() {
        addSubview(leftBar)
        leftBar.top(to: self)
        leftBar.bottom(to: self)
        leftBar.right(to: self)
        leftConstraint = leftBar.left(to: self)
    }
}

// MARK: - Styleable
extension ProgressBar: Styleable {
    func stylize() {
        backgroundColor = .auth_blue20
        leftBar.backgroundColor  = .auth_blue
    }
}
