//
//  QRCodeCoordinator
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

final class QRCodeCoordinator: Coordinator {
    private var rootViewController: UIViewController
    private var qrCodeViewController: QRCodeViewController
    private var connectViewCoordinator: ConnectViewCoordinator?
    private var instantActionCoordinator:  InstantActionCoordinator?

    var dismissClosure: (() -> ())?

    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        self.qrCodeViewController = QRCodeViewController()
    }

    func start() {
        dismissClosure = qrCodeViewController.shouldDismissClosure
        qrCodeViewController.delegate = self
        if let navController = rootViewController.navigationController {
            navController.present(qrCodeViewController, animated: true)
        } else {
            rootViewController.present(qrCodeViewController, animated: true)
        }
    }

    func stop() {}
}

// MARK: - QRCodeViewControllerDelegate
extension QRCodeCoordinator: QRCodeViewControllerDelegate {
    func metadataReceived(data: String?) {
        guard let data = data, let url = URL(string: data),
            SEConnectHelper.isValid(deepLinkUrl: url) else { return }

        if let actionGuid = SEConnectHelper.actionGuid(from: url),
            let connectUrl = SEConnectHelper.connectUrl(from: url) {
            instantActionCoordinator = InstantActionCoordinator(
                rootViewController: rootViewController,
                qrUrl: url,
                actionGuid: actionGuid,
                connectUrl: connectUrl
            )
            instantActionCoordinator?.start()
        } else {
            connectViewCoordinator = ConnectViewCoordinator(
                rootViewController: rootViewController,
                connectionType: .newConnection(data)
            )
            connectViewCoordinator?.start()
        }
    }
}
