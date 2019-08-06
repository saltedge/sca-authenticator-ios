//
//  ReachabilityManager.swift
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

import Foundation
import Reachability

class ReachabilityManager {
    static let shared = ReachabilityManager()

    private var reachability: Reachability!

    var isReachable: Bool {
        return reachability.connection != .none
    }

    func observeReachability() {
        self.reachability = Reachability()
        NotificationsHelper.observe(
            self,
            selector: #selector(self.reachabilityChanged),
            name: NSNotification.Name.reachabilityChanged,
            object: nil
        )

        do {
            try self.reachability.startNotifier()
        } catch {
            print("Error occured while starting reachability notifications : \(error.localizedDescription)")
        }
    }

    @objc func reachabilityChanged(note: Notification) {
        guard let reachability = note.object as? Reachability else { return }

        switch reachability.connection {
        case .cellular:
            NotificationsHelper.post(.networkConnectionIsReachable)
            print("Network available via Cellular Data.")
        case .wifi:
            NotificationsHelper.post(.networkConnectionIsReachable)
            print("Network available via WiFi.")
        case .none:
            NotificationsHelper.post(.networkConnectionIsNotReachable)
            print("Network is not available.")
        }
    }

    deinit {
        NotificationsHelper.removeObserver(self)
    }
}
