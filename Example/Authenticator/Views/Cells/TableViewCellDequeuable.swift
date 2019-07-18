//
//  TableViewCellDequeuable.swift
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

protocol Dequeuable: class {
    static var dequeueIdentifier: String { get }
}

extension Dequeuable where Self: UITableViewCell {
    static var dequeueIdentifier: String {
        return NSStringFromClass(self)
    }
}

extension UITableView {
    func register<T: UITableViewCell>(_: T.Type) where T: Dequeuable {
        self.register(T.self, forCellReuseIdentifier: T.dequeueIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T where T: Dequeuable {
        guard let cell = dequeueReusableCell(withIdentifier: T.dequeueIdentifier, for: indexPath as IndexPath) as? T else {
            fatalError("Cannot dequeue: \(T.self) with identifier: \(T.dequeueIdentifier)")
        }

        return cell
    }
}
