//
//  CustomButton.swift
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

private struct Layout {
    static let cornerRadius: CGFloat = 8.0
    static let height: CGFloat = 42.0
}

class CustomButton: TaptileFeedbackButton {
    enum Style {
        case filled
        case bordered
    }

    override var shadowColor: CGColor {
        return UIColor.auth_blue.withAlphaComponent(0.3).cgColor
    }

    init(_ style: CustomButton.Style, text: String, height: CGFloat = Layout.height) {
        super.init()
        style == .filled ? setupFilledButton() : setupBorderedButton()
        setTitle(text, for: .normal)
        layer.cornerRadius = Layout.cornerRadius
        self.height(height)
    }

    private func setupFilledButton() {
        backgroundColor = .auth_blue
        titleLabel?.font = .auth_15regular
    }

    private func setupBorderedButton() {
        setTitleColor(.auth_blue, for: .normal)
        titleLabel?.font = .auth_15medium
        layer.borderColor = UIColor.auth_blue.cgColor
        layer.borderWidth = 1.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
