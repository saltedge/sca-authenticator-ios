//
//  BordersExtensions.swift
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

private struct Layout {
    static let leftPartialOffset: CGFloat = 15.0
}

enum BorderType {
    case none
    case top
    case bottom
    case partialTop
    case partialBottom
}

extension UIView {
    func setupBorders(for borders: BorderType...) {
        _ = setBorders(for: borders)
    }

    @discardableResult
    func setBorders(for borders: [BorderType]) -> [UIView] {
        var bordersViews = [UIView]()
        borders.forEach { type in
            guard type != .none else { return }

            let border = SeparatorView()
            bordersViews.append(border)
            border.backgroundColor = .auth_lightGray50
            addSubview(border)
            switch type {
            case .top:
                border.left(to: self)
                border.right(to: self)
                border.top(to: self)
            case .bottom:
                border.left(to: self)
                border.right(to: self)
                border.bottom(to: self)
            case .partialTop:
                border.left(to: self)
                border.right(to: self)
                border.top(to: self, offset: Layout.leftPartialOffset)
            case .partialBottom:
                border.left(to: self, offset: Layout.leftPartialOffset)
                border.right(to: self)
                border.bottom(to: self)
            default: break
            }
        }
        return bordersViews
    }
}
