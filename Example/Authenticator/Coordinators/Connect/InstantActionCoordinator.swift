//
//  InstantActionCoordinator
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
import SEAuthenticator

final class InstantActionCoordinator: Coordinator {
    private var rootViewController: UIViewController
    private var connectViewController: ConnectViewController

    init(rootViewController: UIViewController, qrUrl: URL, actionGuid: GUID, connectUrl: URL) {
        self.rootViewController = rootViewController
        self.connectViewController = ConnectViewController()
        handleQr(qrUrl: qrUrl, actionGuid: actionGuid, connectUrl: connectUrl)
    }

    func start() {
        rootViewController.present(
            UINavigationController(rootViewController: connectViewController),
            animated: true
        )
    }

    func stop() {}

    private func handleQr(qrUrl: URL, actionGuid: GUID, connectUrl: URL) {
        guard ConnectionsCollector.activeConnections.count > 0 else {
            finishConnectWithError(l10n(.noActiveConnection))
            return
        }

        connectViewController.title = l10n(.newAction)

        let connections = ConnectionsCollector.activeConnections(by: connectUrl)

        if connections.count > 1 {
            presentConnectionPicker(with: connections, actionGuid: actionGuid, connectUrl: connectUrl, qrUrl: qrUrl)
        } else if connections.count == 1 {
            guard let connection = connections.first else { return }

            submitAction(
                for: connection.guid,
                accessToken: connection.accessToken,
                connectUrl: connectUrl,
                actionGuid: actionGuid,
                qrUrl: qrUrl
            )
        } else {
            dismissConnectWithError(l10n(.noSuitableConnection))
        }
    }

    private func presentConnectionPicker(with connections: [Connection], actionGuid: GUID, connectUrl: URL, qrUrl: URL) {
        let pickerViewModel = ConnectionPickerViewModel(connections: connections)
        let pickerViewController = ConnectionPickerViewController(viewModel: pickerViewModel)
        connectViewController.title = l10n(.chooseConnection)
        if #available(iOS 13.0, *) {
            pickerViewController.isModalInPresentation = false
        }
        connectViewController.add(pickerViewController)

        pickerViewModel.selectedConnectionClosure = { guid, accessToken in
            pickerViewController.remove()
            self.connectViewController.title = l10n(.newAction)
            self.submitAction(
                for: guid,
                accessToken: accessToken,
                connectUrl: connectUrl,
                actionGuid: actionGuid,
                qrUrl: qrUrl
            )
        }
    }

    private func submitAction(for connectionGuid: GUID, accessToken: AccessToken, connectUrl: URL, actionGuid: GUID, qrUrl: URL) {
        let actionData = SEActionRequestData(
            url: connectUrl,
            connectionGuid: connectionGuid,
            accessToken: accessToken,
            appLanguage: UserDefaultsHelper.applicationLanguage,
            guid: actionGuid
        )

        SEActionManager.submitAction(
            data: actionData,
            onSuccess: { [weak self] response in
                self?.handleActionResponse(response, qrUrl: qrUrl)
            },
            onFailure: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.finishConnectWithError(l10n(.actionError))
                }
            }
        )
    }

    private func handleActionResponse(_ response: SESubmitActionResponse, qrUrl: URL) {
        if let connectionId = response.connectionId,
            let authorizationId = response.authorizationId {
            connectViewController.dismiss(animated: true)
        } else {
            if let returnTo = SEConnectHelper.returnToUrl(from: qrUrl) {
                UIApplication.shared.open(returnTo)
            } else {
                connectViewController.dismiss(animated: true)
            }
        }
    }

    func finishConnectWithError(_ error: String) {
        connectViewController.showCompleteView(with: .fail, title: error, description: l10n(.tryAgain))
    }

    func dismissConnectWithError(_ error: String) {
        connectViewController.dismiss(
            animated: true,
            completion: {
                self.rootViewController.present(message: error, style: .error)
            }
        )
    }
}
