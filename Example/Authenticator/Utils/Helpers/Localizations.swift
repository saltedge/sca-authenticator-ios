//
//  Localizations.swift
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

import Foundation

func l10n(_ localization: Localizations) -> String {
    return LocalizationHelper.localizedString(for: localization.rawValue) ?? ""
}

enum Localizations: String, Localizable {
    case add = "actions.add"
    case allow = "actions.allow"
    case back = "actions.back"
    case cancel = "actions.cancel"
    case delete = "actions.delete"
    case ok = "actions.ok"
    case warning = "errors.warning"
    case done = "actions.done"
    case next = "actions.next"
    case authenticator = "authorization.screen.name"

    // MARK: - Onboarding
    case getStarted = "actions.get_started"
    case skip = "actions.skip"

    case firstFeature = "onboarding.carousel_one.title"
    case firstFeatureDescription = "onboarding.carousel_one.description"
    case secondFeature = "onboarding.carousel_two.title"
    case secondFeatureDescription = "onboarding.carousel_two.description"
    case thirdFeature = "onboarding.carousel_three.title"
    case thirdFeatureDescription = "onboarding.carousel_three.description"
    case scanQrDescription = "onboarding.qr.description"

    // MARK: - Setup App
    case secureApp = "onboarding.secure_app.passcode_title"
    case allowTouchID = "onboarding.secure_app.touch_id_allow"
    case allowFaceID = "onboarding.secure_app.face_id_allow"
    case allowNotifications = "onboarding.allow_notifications.title"
    case notNow = "actions.not_now"
    case proceed = "actions.proceed"
    case tryAgain = "actions.try_again"
    case notEnabledBiometricsMessage = "onboarding.secure_app.biometrics_message"
    case enableBiometrics = "onboarding.secure_app.enable_biometrics"
    case goToSettings = "onboarding.secure_app.go_to_settings"

    case signUpComplete = "onboarding.find_connection.completed_title"
    case signUpCompleteDescription = "onboarding.find_connection.completed_description"
    case connectionFailed = "in_app.connection.connection_failed"
    case somethingWentWrong = "errors.contact_support"

    case connectedSuccessfullyTitle = "in_app.connect.success_title"
    case connectedSuccessfullyDescription = "in_app.connect.success_description"

    case secureAppDescription = "onboarding.secure_app.passcode_description"
    case allowTouchIdDescription = "onboarding.secure_app.touch_id_description"
    case allowFaceIdDescription = "onboarding.secure_app.face_id_description"
    case allowNotificationsDescription = "onboarding.allow_notifications.description"

    // MARK: - Authorizations
    case authorizations = "in_app.navigation.authorizations"
    case noAuthorizations = "in_app.authorizations.no_authorizations"
    case noAuthorizationsDescription = "in_app.authorizations.no_authorizations_description"
    case confirmAuthorization = "actions.confirm_authorization"
    case confirm = "actions.confirm"
    case deny = "actions.deny"
    case viewMore = "actions.view_more"

    case authorizationExpired = "in_app.authorizations.authorization_expired"
    case active = "authorization.active.title"
    case successfulAuthorization = "authorization.success.title"
    case denied = "authorization.denied.title"
    case timeOut = "authorization.time_out.title"

    case activeMessage = "authorization.active.message"
    case successfulAuthorizationMessage = "authorization.success.message"
    case deniedMessage = "authorization.denied.message"
    case timeOutMessage = "authorization.time_out.message"

    // MARK: - Actions
    case newAction = "instant_action.new_action"
    case instantActionSuccessMessage = "instant_action.success_message"
    case instantActionSuccessDescription = "instant_action.success_description"

    // MARK: - Connections
    case noConnections = "in_app.connect.no_connections"
    case noConnectionsDescription = "in_app.connect.no_connections_description"
    case connections = "in_app.navigation.connections"
    case connectProvider = "action.connect_provider"
    case connectedOn = "in_app.connection.connected_on"
    case deleteConnectionDescription = "in_app.connections_list.delete_connection"
    case processing = "in_app.connect.in_progress"
    case scanQr = "in_app.connect.scan_qr"
    case selectConnection = "in_app.connect.select"
    case newConnection = "in_app.connect.new_connection"

    // MARK: - Settings
    case settings = "in_app.sidebar_menu.settings"
    case deleteAll = "actions.delete_all"
    case deleteAllDataDescription = "actions.confirm_delete_connections"
    case search = "actions.search"
    case licenses = "in_app.settings.licenses"
    case clearData = "in_app.settings.clear_all_data"
    case clearDataDescription = "in_app.settings.clear_all_data_description"

    // MARK: - Security
    case touchID = "in_app.settings.touch_id"
    case faceID = "in_app.settings.face_id"
    case passcode = "in_app.settings.passcode"
    case changePasscode = "actions.change_passcode"
    case wrongPasscodeSingular = "errors.passcode_ios_singular"
    case accountReset = "errors.account_reset"

    case createPasscode = "onboarding.secure_app.passcode_create"
    case repeatPasscode = "onboarding.secure_app.passcode_repeat"
    case enterPasscode = "actions.enter_passcode"
    case enterPasscodeOrUseTouchID = "in_app.passcode_confirmation.title"
    case enterPasscodeOrUseFaceID = "in_app.passcode_confirmation.title2"
    case unlockAuthenticator = "actions.unlock_authenticator"

    // MARK: - About
    case about = "in_app.settings.about"
    case applicationVersion = "in_app.settings.app_version"
    case language = "in_app.settings.language"
    case terms = "in_app.settings.terms_service"
    case copyright = "in_app.settings.copyright"
    case copyrightDescription = "in_app.settings.copyright_description"
    case thankYouForFeedback = "in_app.settings.contact_support_message"
    case couldNotSendMail = "in_app.settings.contact_support_failed"

    // MARK: - Errors
    case actionError = "errors.instant_action.error"
    case noActiveConnection = "errors.no_active_connections"
    case noSuitableConnection = "errors.no_suitable_connection"
    case authorizationNotFound = "errors.authorization_not_found"
    case deniedCamera = "errors.denied_camera"
    case deniedCameraDescription = "errors.denied_camera_description"
    case inactiveConnection = "errors.inactive_connection"
    case noInternetConnection = "errors.no_internet_connection"
    case pleaseTryAgain = "errors.no_internet_connection_try_again"
    case inactivityMessage = "warnings.inactivity_block_message"
    case passcodeDontMatch = "errors.passcode_dont_match"
    case wrongPasscode = "errors.wrong_passcode"

    // MARK: - Connection Options
    case connect = "actions.connect"
    case reconnect = "actions.reconnect"
    case rename = "actions.rename"
    case support = "in_app.settings.support"
    case contactSupport = "in_app.settings.contact_support"
    case reportAProblem = "actions.report_problem"
    case reportABug = "actions.report_bug"

    var localizedLabel: String { return self.rawValue }
}
