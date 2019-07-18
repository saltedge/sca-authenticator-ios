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

private struct MessageBarStyle {
    static let successColor: UIColor = .auth_green
    static let warningColor: UIColor = .auth_yellow
    static let errorColor: UIColor = .auth_red
    static let messageFont: UIFont = .auth_13semibold
}

private struct Layout {
    static let labelOffset: CGFloat = 13.0
    static var defaultHeight: CGFloat = 47.0
}

final class MessageBarView: UIView {
    enum Style {
        case success
        case warning
        case error
    }

    var heightConstraint: Constraint?
    static let defaultDuration: TimeInterval = 3.0

    var defaultHeight: CGFloat {
        let neededHeight = alertLabel.intrinsicContentSize.height + 2.0 * Layout.labelOffset
        return max(neededHeight, Layout.defaultHeight)
    }

    let alertLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    private var style: Style = .success

    init(description: String, style: Style) {
        super.init(frame: .zero)
        self.style = style
        addSubview(alertLabel)
        alertLabel.text = description
        layout()
        stylize()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension MessageBarView: Layoutable {
    func layout() {
        alertLabel.edges(to: self, insets: UIEdgeInsets(top: Layout.labelOffset, left: Layout.labelOffset,
                                                        bottom: -Layout.labelOffset, right: -Layout.labelOffset))
        alertLabel.center(in: self)
    }
}

// MARK: - Style
extension MessageBarView: Styleable {
    func stylize() {
        switch style {
        case .success: backgroundColor = MessageBarStyle.successColor
        case .warning: backgroundColor = MessageBarStyle.warningColor
        case .error:   backgroundColor = MessageBarStyle.errorColor
        }
        alertLabel.font = MessageBarStyle.messageFont
        alertLabel.textColor = .white
    }
}
