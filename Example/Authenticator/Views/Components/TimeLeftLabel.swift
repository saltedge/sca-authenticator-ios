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
    private var secondsLeft: Int = 0

    var completion: (() -> ())?

    init() {
        super.init(frame: .zero)
        textColor = .lightBlue
        font = .boldSystemFont(ofSize: 14.0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(secondsLeft: Int) {
        self.secondsLeft = secondsLeft
        setTimeLeft(secondsLeft)
        if secondsLeft <= 0 {
            completion?()
        }
    }

    private func setTimeLeft(_ timeLeft: Int) {
        let (minutes, seconds) = secondsToMinutesAndSeconds(timeLeft)
        text = timeLeft >= 0 ? "\(minutes):\(String(format: "%02d", seconds))" : "0:00"
    }
}

private extension TimeLeftLabel {
    func secondsToMinutesAndSeconds(_ seconds: Int) -> (minutes: Int, seconds: Int) {
        return (seconds / 60, (seconds % 3600) % 60)
    }
}
