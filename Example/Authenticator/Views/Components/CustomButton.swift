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

class CustomButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            guard backgroundColor != UIColor.secondaryBackground else { return }

            backgroundColor = isHighlighted ? .selectedColor : .darkBlue
        }
    }

    init(text: String, height: CGFloat = Layout.height, textColor: UIColor = .white, backgroundColor: UIColor = .darkBlue) {
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        titleLabel?.font = .systemFont(ofSize: 18.0, weight: .medium)
        setTitle(text, for: .normal)
        setTitleColor(textColor, for: .normal)
        setTitleColor(textColor, for: .highlighted)
        layer.cornerRadius = Layout.cornerRadius
        self.height(height)
        setupShadow()
    }

    func updateTitle(text: String) {
        setTitle(text, for: .normal)
    }

    private func setupShadow() {
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.shadowColor = UIColor(red: 0.051, green: 0.576, blue: 0.973, alpha: 0.2).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 30.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
