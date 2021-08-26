//
//  Connection.swift
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
import RealmSwift

enum ConnectionStatus: String {
    case active
    case inactive
}

@objcMembers final class Connection: Object, Decodable {
    dynamic var id: String = ""
    dynamic var guid: String = UUID().uuidString
    dynamic var name: String = ""
    dynamic var code: String = ""
    dynamic var baseUrlString: String = ""
    dynamic var logoUrlString: String = ""
    dynamic var accessToken: String = ""
    dynamic var status: String = ConnectionStatus.inactive.rawValue
    dynamic var supportEmail: String = ""
    dynamic var geolocationRequired = RealmOptional<Bool>()
    dynamic var createdAt: Date = Date()
    dynamic var updatedAt: Date = Date()
    dynamic var providerId: String?
    dynamic var publicKey: String = ""
    dynamic var apiVersion: String = "1"

    override static func primaryKey() -> String? {
        return #keyPath(Connection.guid)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case guid
        case name
        case code
        case baseUrlString = "connect_url"
        case logoUrlString = "provier_logo_url"
        case accessToken = "access_token"
        case status
        case supportEmail = "support_email"
        case geolocationRequired = "geolocation_required"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case providerId = "provider_id"
        case publicKey = "public_key"
        case apiVersion = "api_version"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        code = try container.decode(String.self, forKey: .code)
        baseUrlString = try container.decode(String.self, forKey: .baseUrlString)
        logoUrlString = try container.decode(String.self, forKey: .logoUrlString)
        accessToken = try container.decode(String.self, forKey: .accessToken)
        status = try container.decode(String.self, forKey: .status)
        supportEmail = try container.decode(String.self, forKey: .supportEmail)
        let boolResult = try decoder.singleValueContainer()
        if boolResult.decodeNil() == false {
            let value = try boolResult.decode(Bool.self)
            geolocationRequired = RealmOptional(value)
         }
        providerId = try container.decode(String.self, forKey: .providerId)
        publicKey = try container.decode(String.self, forKey: .publicKey)
        apiVersion = try container.decode(String.self, forKey: .apiVersion)
        id = try container.decode(String.self, forKey: .id)
        guid = try container.decode(String.self, forKey: .guid)
        createdAt = try container.decode(String.self, forKey: .createdAt).iso8601date ?? Date()
        updatedAt = try container.decode(String.self, forKey: .updatedAt).iso8601date ?? Date()
        super.init()
    }

    required init() {
        super.init()
    }
}

extension Connection {
    var baseUrl: URL? {
        return URL(string: baseUrlString)
    }

    var logoUrl: URL? {
        return URL(string: logoUrlString)
    }

    var isManaged: Bool {
        return realm != nil
    }

    var isApiV2: Bool {
        return apiVersion == "2"
    }

    var providerPublicKeyTag: String {
        return "\(guid)_provider_public_key"
    }
}
