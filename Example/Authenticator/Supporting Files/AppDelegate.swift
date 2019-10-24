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
import UserNotifications
import Firebase
import SEAuthenticator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    var tabBarViewController: MainTabBarViewController? {
        if let tabBar = self.window?.rootViewController as? MainTabBarViewController {
            return tabBar
        }
        return nil
    }

    var applicationCoordinator: ApplicationCoordinator?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        UNUserNotificationCenter.current().delegate = self
        ReachabilityManager.shared.observeReachability()
        AppearanceHelper.setup()
        CacheHelper.setDefaultDiskAge()
        configureFirebase()
        setupAppCoordinator()
        return true
    }

    private func configureFirebase() {
        if let configFile = Bundle.authenticator_main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let options = FirebaseOptions(contentsOfFile: configFile) {
            FirebaseApp.configure(options: options)
        } else {
            print("For using Crashlytics make sure you have GoogleService-Info.plist set.")
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        applicationCoordinator?.openPasscodeIfNeeded()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        applicationCoordinator?.showBiometricsIfEnabled()
    }

    static var main: AppDelegate {
        return UIApplication.appDelegate
    }

    func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?, annotation: Any) -> Bool {
        guard SEConnectHelper.isValid(deepLinkUrl: url) else { return false }

        if UIWindow.topViewController is PasscodeViewController {
            applicationCoordinator?.openConnectViewController(deepLinkUrl: url)
        }
        return true
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02x", $0) }.joined()

        UserDefaultsHelper.pushToken = deviceTokenString
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        guard let apsDict = userInfo[SENetKeys.aps] as? [String: Any],
            let dataDict = apsDict[SENetKeys.data] as? [String: Any],
            let connectionId = dataDict[SENetKeys.connectionId] as? String,
            let authorizationId = dataDict[SENetKeys.authorizationId] as? String else { completionHandler(); return }

        if UIWindow.topViewController is PasscodeViewController {
            applicationCoordinator?.handleAuthorizationsFromPasscode(connectionId: connectionId, authorizationId: authorizationId)
        } else {
            self.applicationCoordinator?.showAuthorizations(connectionId: connectionId, authorizationId: authorizationId)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .alert, .sound])
    }

    func showApplicationResetPopup() {
        if let topController = UIWindow.topViewController {
            let alert = UIAlertController(title: l10n(.accountReset), message: nil, preferredStyle: .alert)
            topController.present(alert, animated: true, completion: nil)

            after(3.0) { alert.dismiss(animated: true, completion: nil) }
        }
    }

    private func setupAppCoordinator() {
        applicationCoordinator = ApplicationCoordinator(window: window)
        applicationCoordinator?.start()
        applicationCoordinator?.openPasscodeIfNeeded()
        applicationCoordinator?.showBiometricsIfEnabled()
    }
}
