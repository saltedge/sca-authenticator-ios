//
//  PasscodeCoordinator.swift
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

final class PasscodeCoordinator: Coordinator {
    private var rootViewController: UIViewController
    private var currentViewController: PasscodeViewController

    private var purpose: PasscodeViewModel.PasscodeViewMode
    private var viewModel: PasscodeViewModel

    var onCompleteClosure: (() -> ())?

    init(rootViewController: UIViewController, purpose: PasscodeViewModel.PasscodeViewMode) {
        self.purpose = purpose
        self.rootViewController = rootViewController
        self.viewModel = PasscodeViewModel(purpose: purpose)
        self.currentViewController = PasscodeViewController(viewModel: viewModel)
    }

    func start() {
        viewModel.delegate = self

        currentViewController.completeClosure = {
            self.onCompleteClosure?()
        }

        if purpose == .edit {
            rootViewController.navigationController?.pushViewController(currentViewController, animated: true)
        } else {
            currentViewController.modalPresentationStyle = .overFullScreen
            rootViewController.present(currentViewController, animated: true)
        }
    }

    func stop() {}
}

extension PasscodeCoordinator: PasscodeEventsDelegate {
    func showBiometrics() {
        viewModel.showBiometrics(
            completion: {
                self.onCompleteClosure?()
            }
        )
    }

    func dismiss(completion: (() -> ())?) {
        currentViewController.dismiss(
            animated: true,
            completion: completion
        )
    }

    func popToRootViewController() {
        currentViewController.navigationController?.popToViewController(rootViewController, animated: true)
    }

    func presentWrongPasscodeAlert(with message: String, title: String?, buttonTitle: String?) {
        if let title = title, let buttonTitle = buttonTitle {
            currentViewController.showConfirmationAlert(withTitle: title, message: message, cancelTitle: buttonTitle)
        } else {
            currentViewController.presentWrongPasscodeAlert(message: message)
        }
    }

    func dismissWrongPasscodeAlert() {
        currentViewController.dismissWrongPasscodeAlert()
    }
}
