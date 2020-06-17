//
//  MessageBarView.swift
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
    static let labelOffset: CGFloat = 13.0
}

final class MessageBarView: UIView {
    var heightConstraint: Constraint?

    static let defaultDuration: TimeInterval = 5.0

    var defaultHeight: CGFloat = 60.0

    let alertLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14.0)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .titleColor
        return label
    }()
   
    init(description: String) {
        super.init(frame: .zero)
        layer.masksToBounds = true
        layer.cornerRadius = 6.0
        alertLabel.text = description
        backgroundColor = .lightGray
        layout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension MessageBarView: Layoutable {
    func layout() {
        addSubview(alertLabel)

        alertLabel.top(to: self, offset: Layout.labelOffset)
        alertLabel.left(to: self, offset: Layout.labelOffset)
        alertLabel.right(to: self, offset: -Layout.labelOffset)
        alertLabel.bottom(to: self, offset: -Layout.labelOffset)
        alertLabel.center(in: self)
    }
}
