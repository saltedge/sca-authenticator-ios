//
//  DictionaryExtensions.swift
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

extension Dictionary {
    func merge(with other: Dictionary) -> Dictionary {
        var copy = self
        for (k, v) in other {
            copy.updateValue(v, forKey: k)
        }
        return copy
    }

    var jsonString: String? {
        if let data = try? JSONSerialization.data(withJSONObject: self, options: []),
            let string = String(data: data, encoding: String.Encoding.utf8) {
            return string
        }
        return nil
    }
}

extension Dictionary where Key: Hashable, Value: Any {
    static func == (lhs: [Key: Value], rhs: [Key: Value]) -> Bool {
        return NSDictionary(dictionary: lhs).isEqual(to: rhs)
    }
}
