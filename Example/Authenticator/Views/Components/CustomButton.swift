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
    static let cornerRadius: CGFloat = 4.0
    static let height: CGFloat = 48.0
}

// TODO: Remove bordered button type
class CustomButton: UIButton {
    enum Style {
        case filled
        case bordered
    }

    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .primaryDark : .darkBlue
        }
    }

    init(_ style: CustomButton.Style, text: String, height: CGFloat = Layout.height) {
        super.init(frame: .zero)
        style == .filled ? setupFilledButton() : setupBorderedButton()
        setTitle(text, for: .normal)
        setTitleColor(.white, for: [.normal, .selected, .highlighted, .focused])
        layer.cornerRadius = Layout.cornerRadius
        self.height(height)
        setupShadow()
    }

    private func setupShadow() {
        layer.shadowColor = UIColor(red: 0.051, green: 0.576, blue: 0.973, alpha: 0.2).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.shadowOpacity = 1
        layer.shadowRadius = 30.0
    }

    private func setupFilledButton() {
        backgroundColor = .darkBlue
        titleLabel?.font = .systemFont(ofSize: 18.0, weight: .medium)
    }

    private func setupBorderedButton() {
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .auth_15medium
        layer.borderColor = UIColor.auth_blue.cgColor
        layer.borderWidth = 1.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
