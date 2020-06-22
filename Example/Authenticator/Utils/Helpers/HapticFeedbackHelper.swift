//
//  HapticFeedbackHelper.swift
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
import AudioToolbox

struct HapticFeedbackHelper {
    static func produceErrorFeedback() {
        DispatchQueue.main.async {
            if isFeedbackSupport {
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(.error)
            } else {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            }
        }
    }

    static func produceSelectionChangedFeedback() {
        DispatchQueue.main.async {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }

    static func produceImpactFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    private static var isFeedbackSupport: Bool {
        if let value = UIDevice.current.value(forKey: "_feedbackSupportLevel"), let result = value as? Int {
    //        0 = Taptic not available
    //        1 = First generation (tested on an iPhone 6s) ... which does NOT support UINotificationFeedbackGenerator, etc.
    //        2 = Second generation (tested on an iPhone 7) ... which does support it.
            return result == 2 ? true : false
        }
        return false
    }
}
