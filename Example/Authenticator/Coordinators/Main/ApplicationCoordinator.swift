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

    private var passcodeShownDueToInactivity: Bool = false

    init(window: UIWindow?) {
        self.window = window
    }

    func start() {
        if UserDefaultsHelper.didShowOnboarding {
            registerTimeoutNotification()
            window?.rootViewController = tabBarCoordinator.rootViewController
            tabBarCoordinator.start()
        } else {
            PasscodeManager.remove()
            UserDefaultsHelper.applicationLanguage = "en"

            let navController = UINavigationController(rootViewController: onboardingCoordinator.onboardingViewController)
            navController.modalPresentationStyle = .fullScreen
            navController.isNavigationBarHidden = true
            window?.rootViewController = navController
            onboardingCoordinator.start()
        }
        window?.makeKeyAndVisible()
    }

    @objc func applicationDidTimeout(notification: NSNotification) {
        guard let topController = UIWindow.topViewController,
            !topController.isKind(of: PasscodeViewController.self) else { return }

        passcodeShownDueToInactivity = true
        disableTimeoutNotification()
        openPasscodeIfNeeded()
        showBiometricsIfEnabled()
    }

    func registerTimeoutNotification() {
        disableTimeoutNotification()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidTimeout(notification:)),
            name: .appTimeout,
            object: nil
        )
    }

    func disableTimeoutNotification() {
        NotificationCenter.default.removeObserver(self, name: .appTimeout, object: nil)
    }

    func stop() {}

    func showAuthorizations(connectionId: String, authorizationId: String) {
        if (tabBarCoordinator.rootViewController.presentedViewController as? UINavigationController) != nil {
            tabBarCoordinator.rootViewController.dismiss(animated: false, completion: nil)
        }

        tabBarCoordinator.rootViewController.selectedIndex = TabBarControllerType.authorizations.rawValue

        tabBarCoordinator.startAuthorizationsCoordinator(with: connectionId, authorizationId: authorizationId)
    }

    func openConnectViewController(deepLinkUrl: URL? = nil, connectionType: ConnectionType) {
        if (tabBarCoordinator.rootViewController.presentedViewController as? UINavigationController) != nil {
            tabBarCoordinator.rootViewController.dismiss(animated: false, completion: nil)
        }

        tabBarCoordinator.rootViewController.selectedIndex = TabBarControllerType.connections.rawValue

        guard let rootVc = window?.rootViewController else { return }

        passcodeCoordinator?.onCompleteClosure = { [weak self] in
            self?.connectViewCoordinator = ConnectViewCoordinator(
                rootViewController: rootVc,
                connectionType: connectionType,
                deepLinkUrl: deepLinkUrl
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

    private func presentPasscode() {
        guard let topController = UIWindow.topViewController else { return }

        passcodeCoordinator = PasscodeCoordinator(
            rootViewController: topController,
            purpose: .enter,
            type: .main
        )
        passcodeCoordinator?.start()
        passcodeCoordinator?.onCompleteClosure = {
            TimerApplication.resetIdleTimer()
            self.registerTimeoutNotification()
            if !self.passcodeShownDueToInactivity {
                self.tabBarCoordinator.startAuthorizationsCoordinator()
            }
        }
    }

    private func removeAlertControllerIfPresented() {
        if let alertViewController = UIWindow.topViewController as? UIAlertController {
            alertViewController.dismiss(animated: false)
        }
    }
}
