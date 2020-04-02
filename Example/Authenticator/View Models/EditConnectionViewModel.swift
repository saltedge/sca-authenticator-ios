//
//  EditConnectionViewModel
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

enum EditConnectionViewState: Equatable {
    case alert(text: String)
    case edit(defaultName: String?)
    case finish

    static func == (lhs: EditConnectionViewState, rhs: EditConnectionViewState) -> Bool {
        switch (lhs, rhs) {
        case (.finish, .finish):
            return true
        case let (.alert(name1), .alert(name2)):
            return name1 == name2
        case let (.edit(name1), .edit(name2)):
            return name1 == name2
        default: return false
        }
    }
}

class EditConnectionViewModel {
    private var connection: Connection!
    var state = Observable<EditConnectionViewState>(.edit(defaultName: nil))

    init(connectionId: String) {
        guard let connection = ConnectionsCollector.with(id: connectionId) else { return }

        self.connection = connection
        self.state.value = .edit(defaultName: connection.name)
    }

    func updateName(with name: String?) {
        guard let name = name else { return }

        guard !ConnectionsCollector.connectionNames.contains(name) else {
            state.value = .alert(text: "This name already exists.")
            return
        }

        try? RealmManager.performRealmWriteTransaction {
            self.connection.name = name
            state.value = .finish
        }
    }

    func didDismissAlert() {
        state.value = .edit(defaultName: nil)
    }
}
