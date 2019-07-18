//
//  EntityResponse.swift
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

protocol EntityResponse {
    var dictionaryRepresentation: [String: Any] { get }
}

extension EntityResponse {
    var dictionaryRepresentation: [String: Any] {
        let mirror = Mirror(reflecting: self)
        var result: [String: Any] = [:]

        for attribute in mirror.children {
            if let label = attribute.label,
                let value = unwrap(attribute.value) {
                result[label] = value
            }
        }
        return result
    }

    private func unwrap(_ any: Any) -> Any? {
        let mi = Mirror(reflecting: any)
        if mi.displayStyle != .optional {
            return any
        }
        if mi.children.count == 0 {
            return nil
        }
        let (_, value) = mi.children.first!
        return value
    }
}
