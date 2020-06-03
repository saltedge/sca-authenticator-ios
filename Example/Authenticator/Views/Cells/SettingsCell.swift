//
//  SettingsCell.swift
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

final class SettingsCell: UITableViewCell, Dequeuable {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        backgroundColor = .backgroundColor
        textLabel?.textColor = .titleColor
        textLabel?.font = .auth_17regular
        detailTextLabel?.textColor = .titleColor
        detailTextLabel?.font = .auth_13regular
        contentView.tintColor = .extraLightGray
    }

    func set(with item: SettingCellModel) {
        imageView?.image = item.icon
        textLabel?.text = item.localizedLabel
        if let detailsText = item.detailString {
            detailTextLabel?.text = detailsText
        }
        switch item {
        case .clearData: textLabel?.textColor = .redAlert
        default: break
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
