//
//  TimerApplication
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

extension Notification.Name {
    static let appTimeout = Notification.Name("appTimeout")
    static let resetTimer = Notification.Name("reset_timer")
}

class TimerApplication: UIApplication {
    private static var timeoutInSeconds: TimeInterval {
        return 60.0 // NOTE: One minute
    }

    private static var idleTimer: Timer?

    static func resetIdleTimer() {
        if let idleTimer = idleTimer {
            idleTimer.invalidate()
        }

        idleTimer = Timer.scheduledTimer(
            timeInterval: timeoutInSeconds,
            target: self,
            selector: #selector(timeHasExceeded),
            userInfo: nil,
            repeats: false
        )
    }

    @objc private static func timeHasExceeded() {
        NotificationCenter.default.post(
            name: .appTimeout,
            object: nil
        )
    }

    private static func timerResetNotification() {
        NotificationCenter.default.post(
            name: .resetTimer,
            object: nil
        )
    }

    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)

        if let touches = event.allTouches {
            for touch in touches where touch.phase == .began {
                TimerApplication.resetIdleTimer()
                TimerApplication.timerResetNotification()
            }
        }
    }
}
