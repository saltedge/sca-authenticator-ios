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
    private var instantActionHandler: InstantActionHandler
    private var qrCodeCoordinator: QRCodeCoordinator?

    init(rootViewController: UIViewController, qrUrl: URL, actionGuid: GUID, connectUrl: URL) {
        self.rootViewController = rootViewController
        self.connectViewController = ConnectViewController()
        self.instantActionHandler = InstantActionHandler(qrUrl: qrUrl, actionGuid: actionGuid, connectUrl: connectUrl)
        if #available(iOS 13.0, *) {
            connectViewController.isModalInPresentation = true
        }
    }

    func start() {
        instantActionHandler.delegate = self
        instantActionHandler.startHandling()
        connectViewController.title = l10n(.newAction)
        rootViewController.present(
            UINavigationController(rootViewController: connectViewController),
            animated: true
        )
    }

    func stop() {
        instantActionHandler.delegate = nil
    }
}

// MARK: - InstantActionEventsDelegate
extension InstantActionCoordinator: InstantActionEventsDelegate {
    func shouldPresentConnectionPicker(connections: [Connection]) {
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
            self.instantActionHandler.submitAction(for: guid, accessToken: accessToken)
        }
    }

    func showAuthorization(connectionId: String, authorizationId: String) {
        let authorizationViewController = SingleAuthorizationViewController(
            connectionId: connectionId,
            authorizationId: authorizationId
        )
        authorizationViewController.timerExpiredClosure = {
            self.connectViewController.dismiss(animated: true)
        }
        connectViewController.add(authorizationViewController)
    }

    func shouldDismiss() {
        connectViewController.dismiss(animated: true)
    }

    func shouldDismiss(with error: String) {
        connectViewController.dismiss(
            animated: true,
            completion: {
                self.rootViewController.present(message: error)
            }
        )
    }

    func errorReceived(error: String) {
        connectViewController.showCompleteView(
            with: .fail,
            title: l10n(.somethingWentWrong),
            description: error,
            completion: { [weak self] in
                guard let strongSelf = self else { return }

                strongSelf.connectViewController.dismiss(animated: true) {
                    strongSelf.qrCodeCoordinator = QRCodeCoordinator(rootViewController: strongSelf.rootViewController)
                    strongSelf.qrCodeCoordinator?.start()
                }
            }
        )
    }
}
