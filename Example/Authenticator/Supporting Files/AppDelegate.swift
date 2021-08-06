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
import SEAuthenticatorCore

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    var applicationCoordinator: ApplicationCoordinator?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        UNUserNotificationCenter.current().delegate = self
        ConnectivityManager.shared.observeReachability()
        AppearanceHelper.setup()
        CacheHelper.setDefaultDiskAge()
        configureFirebase()
        LocationManager.shared.startUpdatingLocation()
        setupAppCoordinator()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if UserDefaultsHelper.didShowOnboarding {
            applicationCoordinator?.registerTimerNotifications()
        }
        QuickActionsHelper.setupActions()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        TimerApplication.resetIdleTimer()
        applicationCoordinator?.disableTimerNotifications()
    }

    private func configureFirebase() {
        FirebaseApp.configure()
        if Bundle.authenticator_main.path(forResource: "GoogleService-Info", ofType: "plist") != nil,
           FirebaseApp.app() == nil {
            FirebaseApp.configure()
        } else {
            Log.debugLog(message: "For using Crashlytics make sure you have GoogleService-Info.plist set.")
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        TimerApplication.resetIdleTimer()
        applicationCoordinator?.disableTimerNotifications()
        applicationCoordinator?.openPasscodeIfNeeded()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if UserDefaultsHelper.didShowOnboarding {
            applicationCoordinator?.registerTimerNotifications()
        }
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        applicationCoordinator?.showBiometricsIfEnabled()
        applicationCoordinator?.openQrScannerIfNoConnections()
    }

    static var main: AppDelegate {
        return UIApplication.appDelegate
    }

    func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?, annotation: Any) -> Bool {
        guard SEConnectHelper.isValid(deepLinkUrl: url) else { return false }

        if UIWindow.topViewController is PasscodeViewController {
            applicationCoordinator?.openConnectViewController(url: url)
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
        Log.debugLog(message: error.localizedDescription)
    }

    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        if AVCaptureHelper.cameraIsAuthorized(), shortcutItem.type == QuickActionsType.openCamera.rawValue {
            applicationCoordinator?.openQrScanner()
            completionHandler(true)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let (connectionId, authorizationId) = extractIds(from: response.notification.request) else {
            completionHandler()
            return
        }

        if UIWindow.topViewController is PasscodeViewController {
            applicationCoordinator?.handleAuthorizationsFromPasscode(connectionId: connectionId, authorizationId: authorizationId)
        } else {
            self.applicationCoordinator?.showAuthorizations(connectionId: connectionId, authorizationId: authorizationId)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard let (connectionId, _) = extractIds(from: notification.request) else { return }

        if ConnectionsCollector.active(by: connectionId) != nil {
            completionHandler([.badge, .alert, .sound])
        }
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
        applicationCoordinator?.openQrScannerIfNoConnections()
    }

    private func extractIds(from request: UNNotificationRequest) -> (String, String)? {
        let userInfo = request.content.userInfo

        guard let apsDict = userInfo[SENetKeys.aps] as? [String: Any],
              let dataDict = apsDict[SENetKeys.data] as? [String: Any] else { return nil }

        // NOTE: connection_id and authorization_id from v1 are strings, from v2 - ints
            if let connectionId = dataDict[SENetKeys.connectionId] as? String,
               let authorizationId = dataDict[SENetKeys.authorizationId] as? String {
                return (connectionId, authorizationId)
            } else if let connectionId = dataDict[SENetKeys.connectionId] as? Int,
                      let authorizationId = dataDict[SENetKeys.authorizationId] as? Int {
                return ("\(connectionId)", "\(authorizationId)")
            } else {
                return nil
            }
    }
}
