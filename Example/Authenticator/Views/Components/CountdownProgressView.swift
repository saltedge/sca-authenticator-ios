//
//  CountdownProgressLeftView.swift
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

final class CountdownProgressView: UIView {
    private let progressView = UIProgressView()
    private var secondsLeft: Int = 0
    private var lifetime: Int = 0

    init() {
        super.init(frame: .zero)
        progressView.progress = Float(secondsLeft) / Float(lifetime)
        progressView.progressTintColor = .auth_blue
        progressView.trackTintColor = .clear
        layout()
        setTimeLeft(secondsLeft)
    }

    func update(secondsLeft: Int, lifetime: Int) {
        self.secondsLeft = secondsLeft
        self.lifetime = lifetime
        setTimeLeft(secondsLeft)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helpers
private extension CountdownProgressView {
    func setTimeLeft(_ timeLeft: Int) {
        progressView.progress = Float(timeLeft) / Float(lifetime)
        progressView.setProgress(progressView.progress, animated: true)
    }
}

// MARK: - Layout
extension CountdownProgressView: Layoutable {
    func layout() {
        addSubviews(progressView)

        progressView.edges(to: self)
    }
}
