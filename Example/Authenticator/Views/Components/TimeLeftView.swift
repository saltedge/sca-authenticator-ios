//
//  TimeLeftView.swift
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
    static let interItemOffset: CGFloat = 5.0
    static let indicatorSize: CGSize = CGSize(width: 20.0, height: 20.0)
}

final class TimeLeftView: UIView {
    private let timeLeftLabel = UILabel()
    private var timeLeftIndicator: TimeLeftIndicator!
    private let completion: () -> ()
    private var timer: Timer!
    private var secondsLeft: Int
    private var lifetime: Int

    init(secondsLeft: Int, lifetime: Int, completion: @escaping () -> ()) {
        self.secondsLeft = secondsLeft
        self.lifetime = lifetime
        self.completion = completion
        super.init(frame: .zero)
        timeLeftIndicator = TimeLeftIndicator(percentage: 1.0 - CGFloat(secondsLeft) / CGFloat(lifetime))
        layout()
        stylize()
        setTimer()
        setTimeLeft(secondsLeft)
    }

    func update(secondsLeft: Int, lifetime: Int) {
        self.secondsLeft = secondsLeft
        self.lifetime = lifetime
        setTimer()
        setTimeLeft(secondsLeft)
    }

    deinit {
        timer.invalidate()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helpers
private extension TimeLeftView {
    func secondsToMinutesAndSeconds(_ seconds: Int) -> (minutes: Int, seconds: Int) {
        return (seconds / 60, (seconds % 3600) % 60)
    }

    func setTimer() {
        if timer != nil { timer.invalidate() }
        timer = Timer(timeInterval: 1, target: self, selector: #selector(countDownTime), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
    }

    func setTimeLeft(_ timeLeft: Int) {
        timeLeftIndicator.update(with: 1.0 - CGFloat(timeLeft) / CGFloat(lifetime))
        let (minutes, seconds) = secondsToMinutesAndSeconds(timeLeft)
        timeLeftLabel.text = "\(minutes):\(String(format: "%02d", seconds))"
    }
}

// MARK: - Actions
private extension TimeLeftView {
    @objc func countDownTime() {
        secondsLeft -= 1
        if secondsLeft <= 0 {
            timer.invalidate()
            completion()
        } else {
            setTimeLeft(secondsLeft)
        }
    }
}

// MARK: - Layout
extension TimeLeftView: Layoutable {
    func layout() {
        addSubviews(timeLeftLabel, timeLeftIndicator)

        timeLeftLabel.left(to: self)
        timeLeftLabel.top(to: self)
        timeLeftLabel.bottom(to: self)

        timeLeftIndicator.right(to: self)
        timeLeftIndicator.centerY(to: self)
        timeLeftIndicator.leftToRight(of: timeLeftLabel, offset: Layout.interItemOffset)
        timeLeftIndicator.size(Layout.indicatorSize)
    }
}

// MARK: - Style
extension TimeLeftView: Styleable {
    func stylize() {
        timeLeftLabel.textColor = .auth_cyan
        timeLeftLabel.font = .auth_13semibold
    }
}
