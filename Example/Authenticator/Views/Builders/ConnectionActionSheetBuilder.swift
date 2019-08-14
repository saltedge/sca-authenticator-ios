//
//  ConnectionActionSheetBuilder.swift
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

typealias Action = (()->())

enum ActionSheetAction {
    case reconnect
    case support
    case rename
    case delete
}

struct ConnectionActionSheetBuilder {
    static func createActions(from hash: [ActionSheetAction: Action]) -> [CustomActionSheetButton] {
        let actions: [CustomActionSheetButton] = hash.map { (name, action) in
            return button(for: name, action: action)
        }
        return actions
    }

    private static func button(for type: ActionSheetAction, action: @escaping Action) -> CustomActionSheetButton {
        var button: CustomActionSheetButton
        switch type {
        case .reconnect:
            button = CustomActionSheetButton(logo: #imageLiteral(resourceName: "Bank"), title: l10n(.reconnect), action: action)
        case .rename:
            button = CustomActionSheetButton(logo: #imageLiteral(resourceName: "Edit"), title: l10n(.renameConnection), action: action)
        case .support:
            button = CustomActionSheetButton(logo: #imageLiteral(resourceName: "Info"), title: l10n(.contactSupport), action: action)
        case .delete:
            button = CustomActionSheetButton(logo: #imageLiteral(resourceName: "Delete"), title: l10n(.delete), action: action)
        }
        return button
    }
}
