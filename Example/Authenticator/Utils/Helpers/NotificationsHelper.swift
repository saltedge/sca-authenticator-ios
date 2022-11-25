//
//  NotificationsHelper.swift
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

extension Notification.Name {
    static let networkConnectionIsNotReachable = Notification.Name("network-connection-is-not-reachable")
    static let networkConnectionIsReachable = Notification.Name("network-connection-is-reachable")
    static let locationServicesStatusDidChange = Notification.Name("locationServicesStatusDidChange")
}

final class NotificationsHelper {
    private static var notificationCenter: NotificationCenter {
        return NotificationCenter.default
    }

    static func post(_ name: Notification.Name, object: Any? = nil) {
        notificationCenter.post(name: name, object: object)
    }

    static func observe(_ observer: Any, selector: Selector, name: Notification.Name, object: Any? = nil) {
        notificationCenter.addObserver(observer, selector: selector, name: name, object: object)
    }

    static func removeObserver(_ object: Any) {
        notificationCenter.removeObserver(object)
    }
}
