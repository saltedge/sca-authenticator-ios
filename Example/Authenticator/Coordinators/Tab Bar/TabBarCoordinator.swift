//
//  TabBarCoordinator.swift
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

final class TabBarCoordinator: Coordinator {
    let rootViewController = MainTabBarViewController()

    private let authorizationsCoordinator = AuthorizationsCoordinator()
    private let connectionsCoordinator = ConnectionsCoordinator()
    private let settingsCoordinator = SettingsCoordinator()
    private let noActiveConnections = ConnectionsCollector.activeConnections.isEmpty

    var coordinators: [Coordinator] {
        return [connectionsCoordinator, settingsCoordinator]
    }

    init() {
        let authNavController = UINavigationController(rootViewController: authorizationsCoordinator.rootViewController)
        authNavController.tabBarItem = TabBarDataSource.tabBarItem(for: .authorizations)

        let connectionsNavController = UINavigationController(rootViewController: connectionsCoordinator.rootViewController)
        connectionsNavController.tabBarItem = TabBarDataSource.tabBarItem(for: .connections)

        let settingsNavController = UINavigationController(rootViewController: settingsCoordinator.rootViewController)
        settingsNavController.tabBarItem = TabBarDataSource.tabBarItem(for: .settings)

        rootViewController.viewControllers = [authNavController, connectionsNavController, settingsNavController]
    }

    func start() {
        coordinators.forEach { $0.start() }

        rootViewController.onSelect = { index in
            if index != 0 {
                self.authorizationsCoordinator.stop()
            } else {
                self.authorizationsCoordinator.start()
            }
        }

        rootViewController.selectedIndex = noActiveConnections
            ? TabBarControllerType.connections.rawValue : TabBarControllerType.authorizations.rawValue
    }

    func stop() {}

    func startAuthorizationsCoordinator(with connectionId: String? = nil, authorizationId: String? = nil) {
        if let connectionId = connectionId, let authorizationId = authorizationId {
            authorizationsCoordinator.start(with: connectionId, authorizationId: authorizationId)
        } else {
            authorizationsCoordinator.start()
        }
    }
}
