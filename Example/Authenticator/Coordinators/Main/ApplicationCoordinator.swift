//
//  ApplicationCoordinator.swift
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

final class ApplicationCoordinator: Coordinator {
    private let window: UIWindow?
    private lazy var tabBarCoordinator = TabBarCoordinator()
    private lazy var onboardingCoordinator = OnboardingCoordinator()
    private var passcodeCoordinator: PasscodeCoordinator?
    private var connectViewCoordinator: ConnectViewCoordinator?

    init(window: UIWindow?) {
        self.window = window
    }

    func start() {
        if UserDefaultsHelper.didShowOnboarding {
            window?.rootViewController = tabBarCoordinator.rootViewController
            tabBarCoordinator.start()
        } else {
            PasscodeManager.remove()
            UserDefaultsHelper.applicationLanguage = "en"

            let navController = UINavigationController(rootViewController: onboardingCoordinator.onboardingViewController)
            navController.isNavigationBarHidden = true
            window?.rootViewController = navController
            onboardingCoordinator.start()
        }
        window?.makeKeyAndVisible()
    }

    func stop() {}

    func showAuthorizations(connectionId: String, authorizationId: String) {
        if (tabBarCoordinator.rootViewController.presentedViewController as? UINavigationController) != nil {
            tabBarCoordinator.rootViewController.dismiss(animated: false, completion: nil)
        }

        tabBarCoordinator.rootViewController.selectedIndex = TabBarControllerType.authorizations.rawValue

        guard let rootVc = window?.rootViewController else { return }

//        let authModalCoordinator = AuthorizationModalViewCoordinator(
//            rootViewController: rootVc,
//            type: .preFetchAndShow,
//            viewModel: AuthorizationViewModel(connectionId: connectionId, authorizationId: authorizationId)
//        )
//        authModalCoordinator.closePressed = {
//            self.tabBarCoordinator.startAuthorizationsCoordinator()
//        }
//        authModalCoordinator.start()
    }

    func openConnectViewController(urlString: String) {
        if (tabBarCoordinator.rootViewController.presentedViewController as? UINavigationController) != nil {
            tabBarCoordinator.rootViewController.dismiss(animated: false, completion: nil)
        }

        tabBarCoordinator.rootViewController.selectedIndex = TabBarControllerType.connections.rawValue

        guard let rootVc = window?.rootViewController else { return }

        passcodeCoordinator?.onCompleteClosure = { [weak self] in
            self?.connectViewCoordinator = ConnectViewCoordinator(
                rootViewController: rootVc,
                connectionType: .deepLink,
                configurationUrl: urlString
            )

            self?.connectViewCoordinator?.start()
        }
    }

    func handleAuthorizationsFromPasscode(connectionId: String, authorizationId: String) {
        passcodeCoordinator?.onCompleteClosure = {
            self.showAuthorizations(connectionId: connectionId, authorizationId: authorizationId)
        }
    }

    func openPasscodeIfNeeded() {
        guard PasscodeManager.hasPasscode else { return }

        let presentPasscode: () -> () = {
            if let topController = UIWindow.topViewController {
                self.passcodeCoordinator = PasscodeCoordinator(
                    rootViewController: topController,
                    purpose: .enter,
                    type: .main
                )
                self.passcodeCoordinator?.start()
                self.passcodeCoordinator?.onCompleteClosure = {
                    self.tabBarCoordinator.startAuthorizationsCoordinator()
                }
            }
        }
        removeAlertControllerIfPresented()
        if let passcodeVC = UIWindow.topViewController as? PasscodeViewController {
            passcodeVC.dismiss(animated: false, completion: presentPasscode)
        } else {
            presentPasscode()
        }
    }

    func showBiometricsIfEnabled() {
        if UserDefaultsHelper.blockedTill == nil, let passcodeCoordinator = passcodeCoordinator {
            passcodeCoordinator.showBiometricsIfEnabled()
        }
    }

    private func removeAlertControllerIfPresented() {
        if let alertViewController = UIWindow.topViewController as? UIAlertController {
            alertViewController.dismiss(animated: false)
        }
    }
}
