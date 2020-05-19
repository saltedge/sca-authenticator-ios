//
//  CustomActionSheetButton.swift
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2020 Salt Edge Inc.
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

final class CustomActionSheetButton: TaptileFeedbackButton {
    private let buttonTitle: UILabel = {
        let label = UILabel()
        label.textColor = .lightBlue
        label.font = .auth_20regular
        return label
    }()

    private var actionHandler: (() -> ()) = {}

    init(title: String, action: @escaping (() -> ())) {
        super.init()
        buttonTitle.text = title
        actionHandler = action
        setupElements()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Setup
extension CustomActionSheetButton {
    private func setupElements() {
        addSubviews(buttonTitle)
        layout()
        setBorders(for: [.bottom])
        addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }

    private func setupBottomSeparator() {
        let bottomSeparator = SeparatorView(axis: .horizontal)
        bottomSeparator.backgroundColor = .lightGray
        addSubview(bottomSeparator)
        bottomSeparator.edges(to: self)
    }
}

// MARK: Actions
extension CustomActionSheetButton {
    @objc private func buttonPressed() {
        actionHandler()
    }
}

// MARK: Layout
extension CustomActionSheetButton: Layoutable {
    func layout() {
        buttonTitle.center = self.center
    }
}
