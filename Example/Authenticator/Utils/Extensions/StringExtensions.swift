//
//  StringExtensions.swift
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

extension String {
    var json: [String: Any]? {
        if let data = self.data(using: String.Encoding.utf8),
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            return dictionary
        }
        return nil
    }

    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8),
            let attributedString = try? NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            ), attributedString.isAttributed else { return nil }

        return attributedString
    }
}

private extension NSAttributedString {
    var isAttributed: Bool {
        var allAttributes = [[NSAttributedString.Key: Any]]()
        enumerateAttributes(in: NSRange(location: 0, length: length), options: []) { attributes, _, _ in
            allAttributes.append(attributes)
        }

        return allAttributes.count > 1
    }
}
