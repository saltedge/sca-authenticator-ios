//
//  TimeLeftLabel
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

final class TimeLeftLabel: UILabel {
    private var timer: Timer!

    private var secondsLeft: Int = 0

    init() {
        super.init(frame: .zero)
        textColor = .auth_blue
        font = .auth_13semibold
        setTimer()
        setTimeLeft(secondsLeft)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(secondsLeft: Int) {
        self.secondsLeft = secondsLeft
        setTimer()
        setTimeLeft(secondsLeft)
    }

    private func setTimer() {
        if timer != nil { timer.invalidate() }
        timer = Timer(timeInterval: 1.0, target: self, selector: #selector(countDownTime), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
    }

    private func setTimeLeft(_ timeLeft: Int) {
        let (minutes, seconds) = secondsToMinutesAndSeconds(timeLeft)
        text = "\(minutes):\(String(format: "%02d", seconds))"
    }

    @objc private func countDownTime() {
        secondsLeft -= 1
        if secondsLeft <= 0 {
            timer.invalidate()
            text = "0:00"
        } else {
            setTimeLeft(secondsLeft)
        }
    }

    deinit {
        timer.invalidate()
    }
}

private extension TimeLeftLabel {
    func secondsToMinutesAndSeconds(_ seconds: Int) -> (minutes: Int, seconds: Int) {
        return (seconds / 60, (seconds % 3600) % 60)
    }
}
