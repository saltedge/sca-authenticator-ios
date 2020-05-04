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
    private var setupAppCoordinator: SetupAppCoordinator?
    private var passcodeCoordinator: PasscodeCoordinator?
    private var connectViewCoordinator: ConnectViewCoordinator?

    private var passcodeShownDueToInactivity: Bool = false

    private var messageBarView: MessageBarView?

    init(window: UIWindow?) {
        self.window = window
    }

    func start() {
        if UserDefaultsHelper.didShowOnboarding {
            registerTimerNotifications()
            window?.rootViewController = tabBarCoordinator.rootViewController
            tabBarCoordinator.start()
        } else {
            PasscodeManager.remove()
            UserDefaultsHelper.applicationLanguage = "en"

            let onboardingVc = OnboardingViewController()

            onboardingVc.donePressedClosure = {
                let setupVc = SetupAppViewController()
                setupVc.modalPresentationStyle = .fullScreen
                setupVc.receivedQrMetadata = { metadata in
                    self.startTabBarController()

                    if let data = metadata {
                        self.openConnectViewController(url: nil, connectionType: .firstConnect(data))
                    }
                }
                onboardingVc.present(setupVc, animated: true)
            }

            onboardingVc.modalPresentationStyle = .fullScreen
            window?.rootViewController = onboardingVc
        }
        window?.makeKeyAndVisible()
    }

    // TODO: Remove
    private func startTabBarController() {
        UserDefaultsHelper.didShowOnboarding = true

        self.window?.rootViewController = self.tabBarCoordinator.rootViewController
        self.tabBarCoordinator.start()
    }

    func registerTimerNotifications() {
        disableTimerNotifications()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidTimeout(notification:)),
            name: .appTimeout,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dismissMessage),
            name: .resetTimer,
            object: nil
        )
    }

    func disableTimerNotifications() {
        NotificationCenter.default.removeObserver(self, name: .appTimeout, object: nil)
        NotificationCenter.default.removeObserver(self, name: .resetTimer, object: nil)
    }

    func stop() {}

    func showAuthorizations(connectionId: String, authorizationId: String) {
        if (tabBarCoordinator.rootViewController.presentedViewController as? UINavigationController) != nil {
            tabBarCoordinator.rootViewController.dismiss(animated: false, completion: nil)
        }

        tabBarCoordinator.rootViewController.selectedIndex = TabBarControllerType.authorizations.rawValue

        tabBarCoordinator.startAuthorizationsCoordinator(with: connectionId, authorizationId: authorizationId)
    }

    func openConnectViewController(url: URL? = nil, connectionType: ConnectionType) {
        if (tabBarCoordinator.rootViewController.presentedViewController as? UINavigationController) != nil {
            tabBarCoordinator.rootViewController.dismiss(animated: false, completion: nil)
        }

        tabBarCoordinator.rootViewController.selectedIndex = TabBarControllerType.connections.rawValue

        guard let rootVc = window?.rootViewController else { return }

//        passcodeCoordinator?.onCompleteClosure = { [weak self] in
        connectViewCoordinator = ConnectViewCoordinator(
            rootViewController: rootVc,
            connectionType: connectionType,
            deepLinkUrl: url
        )

        connectViewCoordinator?.start()
//        }
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

        let passcodeViewController = PasscodeViewController(purpose: .enter)
        passcodeViewController.modalPresentationStyle = .overFullScreen
        topController.present(passcodeViewController, animated: false)

        passcodeViewController.completeClosure = {
            TimerApplication.resetIdleTimer()
            self.registerTimerNotifications()
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

    @objc func applicationDidTimeout(notification: NSNotification) {
        guard let topController = UIWindow.topViewController,
            !topController.isKind(of: PasscodeViewController.self) else { return }

        var visibleController: UIViewController

        if let tabBarController = topController as? MainTabBarViewController,
            let selectedController = (tabBarController.selectedViewController as? UINavigationController)?.viewControllers.last {
            visibleController = selectedController
        } else {
            visibleController = topController
        }

        messageBarView = visibleController.present(
            message: l10n(.inactivityMessage),
            style: .warning,
            completion: {
                if self.messageBarView != nil {
                    self.passcodeShownDueToInactivity = true
                    self.disableTimerNotifications()
                    self.openPasscodeIfNeeded()
                    self.showBiometricsIfEnabled()
                }
            }
        )
    }

    @objc private func dismissMessage() {
        if let messageView = messageBarView, let topController = UIWindow.topViewController {
            topController.dismiss(messageBarView: messageView)
            messageBarView = nil
        }
    }
}
