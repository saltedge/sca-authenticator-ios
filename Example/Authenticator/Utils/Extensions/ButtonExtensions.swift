//
//  ButtonExtensions
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

private var bindedEvents: [UIButton: EventBinder] = [:]

private class EventBinder {
    let event: UIControl.Event
    let button: UIButton
    let handler: UIButton.EventHandler
    let selector: Selector

    required init(
        _ event: UIControl.Event,
        on button: UIButton,
        withHandler handler: @escaping UIButton.EventHandler
    ) {
        self.event = event
        self.button = button
        self.handler = handler
        self.selector = #selector(performEvent(on:ofType:))
        button.addTarget(self, action: self.selector, for: event)
    }

    deinit {
        button.removeTarget(self, action: selector, for: event)
        if let index = bindedEvents.index(forKey: button) {
            bindedEvents.remove(at: index)
        }
    }
}

private extension EventBinder {
    @objc func performEvent(on sender: UIButton, ofType event: UIControl.Event) {
        handler(sender, event)
    }
}

extension UIButton {
    typealias EventHandler = (UIButton, UIControl.Event) -> Void

    func on(_ event: UIControl.Event, handler: @escaping EventHandler) {
        bindedEvents[self] = EventBinder(event, on: self, withHandler: handler)
    }
}
