//
//  ViewExtensions+Animations.swift
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

extension UIView {
    static var defaultAnimationDuration: TimeInterval {
        return TimeInterval(AnimationConstants.defaultDuration)
    }

    static func withSpringAnimation(duration: TimeInterval = TimeInterval(AnimationConstants.defaultDuration),
                                    damping: CGFloat = 1.0,
                                    delay: TimeInterval = 0.0,
                                    animations closure: @escaping () -> (),
                                    completion: (() -> ())? = nil) {
        UIView.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: damping,
            initialSpringVelocity: AnimationConstants.defaultVelocity / CGFloat(duration),
            options: [],
            animations: {
                closure()
            },
            completion: { completed in
                if completed && (completion != nil) {
                    completion!()
                }
            }
        )
    }

    static func withAnimation(_ closure: @escaping () -> ()) {
        UIView.animate(withDuration: UIView.defaultAnimationDuration, animations: closure)
    }
}
