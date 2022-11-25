//
//  BaseConnectionsInteractor
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2021 Salt Edge Inc.
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
import SEAuthenticatorCore

protocol BaseConnectionsInteractor {
    func createNewConnection(
        from url: URL,
        with connectQuery: String?,
        success: @escaping (Connection, AccessToken) -> (),
        redirect: @escaping (Connection, String) -> (),
        failure: @escaping (String) -> ()
    )
    func submitNewConnection(
        for connection: Connection,
        connectQuery: String?,
        success: @escaping (Connection, AccessToken) -> (),
        redirect: @escaping (Connection, String) -> (),
        failure: @escaping (String) -> ()
    )
    func revoke(_ connection: Connection, success: (() -> ())?, failure: @escaping (String) -> ())
}
