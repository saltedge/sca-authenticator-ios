//
//  AuthorizationModalViewCoordinator.swift
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
import SEAuthenticator

final class AuthorizationModalViewCoordinator: Coordinator {
    private let rootViewController: UIViewController

    private var modalController: AuthorizationModalViewController
    private var viewModel: AuthorizationViewModel
    private var type: AuthorizationModalType
    private weak var timer: Timer?

    var confirmationActionPressed: ((AuthorizationViewModel) -> ())?
    var closePressed: (() -> ())?

    init(rootViewController: UIViewController,
         type: AuthorizationModalType = .show,
         viewModel: AuthorizationViewModel) {
        self.rootViewController = rootViewController
        self.viewModel = viewModel
        self.type = type
        self.modalController = AuthorizationModalViewController(type: type, viewModel: viewModel)
    }

    func start() {
        modalController.modalPresentationStyle = .overCurrentContext
        modalController.modalTransitionStyle = .crossDissolve

        timer = Timer.scheduledTimer(
            timeInterval: 2.0,
            target: self,
            selector: #selector(getAuthorization),
            userInfo: nil,
            repeats: true
        )
        modalController.delegate = self

        rootViewController.present(modalController, animated: false)
    }

    func stop() {
        timer?.invalidate()
        modalController.dismiss(animated: true)
    }

    @objc private func getAuthorization() {
        guard let data = viewModel.toBaseAuthorizationData() else { return }

        SEAuthorizationManager.getEncryptedAuthorization(
            data: data,
            onSuccess: { response in
                guard let data = AuthorizationsPresenter.decryptedData(from: response.data),
                    let newModel = AuthorizationViewModel(data),
                    newModel != self.viewModel else { return }

                self.viewModel = newModel

                self.modalController.setAuthorization(newModel)
            },
            onFailure: { error in
                print(error)
            }
        )
    }
}

// MARK: - AuthorizationModalViewControllerDelegate
extension AuthorizationModalViewCoordinator: AuthorizationModalViewControllerDelegate {
    func denyPressed() {
        guard let connection = ConnectionsCollector.with(id: viewModel.connectionId),
            let baseUrl = connection.baseUrl else { return }

        let data = SEConfirmAuthorizationData(
            url: baseUrl,
            connectionGuid: connection.guid,
            accessToken: connection.accessToken,
            appLanguage: UserDefaultsHelper.applicationLanguage,
            authorizationId: viewModel.authorizationId,
            authorizationCode: viewModel.authorizationCode
        )

        AuthorizationsInteractor.deny(
            data: data,
            success: { [weak self] in
                guard let strongSelf = self else { return }

                strongSelf.confirmationActionPressed?(strongSelf.viewModel)
                strongSelf.stop()
            }
        )
    }

    func confirmPressed() {
        guard let connection = ConnectionsCollector.with(id: viewModel.connectionId),
            let baseUrl = connection.baseUrl else { return }

        let data = SEConfirmAuthorizationData(
            url: baseUrl,
            connectionGuid: connection.guid,
            accessToken: connection.accessToken,
            appLanguage: UserDefaultsHelper.applicationLanguage,
            authorizationId: viewModel.authorizationId,
            authorizationCode: viewModel.authorizationCode
        )

        AuthorizationsInteractor.confirm(
            data: data,
            success: { [weak self] in
                guard let strongSelf = self else { return }

                strongSelf.confirmationActionPressed?(strongSelf.viewModel)
                strongSelf.stop()
            }
        )
    }

    func willBeClosed() {
        timer?.invalidate()
        closePressed?()
    }
}
