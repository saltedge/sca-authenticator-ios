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
    case clear = "actions.clear"
    case clearData = "actions.clear_data"
    case delete = "actions.delete"
    case ok = "actions.ok"
    case warning = "errors.warning"
    case done = "actions.done"
    case next = "actions.next"
    case retry = "actions.retry"
    case authenticator = "authorization.screen.name"
    case forgot = "actions.forgot"
    case remove = "actions.remove"
    case revoke = "actions.revoke"

    // MARK: - Onboarding
    case getStarted = "actions.get_started"
    case skip = "actions.skip"

    case firstFeature = "onboarding.carousel_one.title"
    case firstFeatureDescription = "onboarding.carousel_one.description"
    case secondFeature = "onboarding.carousel_two.title"
    case secondFeatureDescription = "onboarding.carousel_two.description"
    case thirdFeature = "onboarding.carousel_three.title"
    case thirdFeatureDescription = "onboarding.carousel_three.description"
    case scanQrFirstDescription = "onboarding.qr.first_scan_description"
    case scanQrToTakeAnAction = "onboarding.qr.take_action_description"

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

    case forgotPasscode = "no_data.forgot_passcode"
    case forgotPasscodeDescription = "no_data.forgot_passcode_description"
    case forgotPasscodeClearDataDescription = "no_data.forgot_passcode_clear_data_description"

    // MARK: - Actions
    case newAction = "instant_action.new_action"
    case instantActionSuccessMessage = "instant_action.success_message"
    case instantActionSuccessDescription = "instant_action.success_description"
    case processing = "actions.processing"
    case processingDescription = "actions.processing.description"

    // MARK: - Connections
    case noConnections = "in_app.connect.no_connections"
    case noConnectionsDescription = "in_app.connect.no_connections_description"
    case connections = "in_app.navigation.connections"
    case connectProvider = "action.connect_provider"
    case connectedOn = "in_app.connection.connected_on"
    case deleteConnection = "actions.confirm_delete_connection"
    case deleteConnectionDescription = "in_app.connections_list.delete_connection"
    case scanQr = "in_app.connect.scan_qr"
    case scanQrCode = "in_app.connect.scan_qr_code"
    case chooseConnection = "in_app.connect.choose"
    case newConnection = "in_app.connect.new_connection"

    // MARK: - Consents
    case activeConsents = "in_app.connection.active_consents"
    case consent = "in_app.connection.consents_singular"
    case consents = "in_app.connection.consents_plural"
    case day = "in_app.connection.consents.day_singular"
    case days = "in_app.connection.consents.day_plural"
    case daysLeft = "in_app.connection.consents.days_left"
    case expiresIn = "in_app.connection.consents.expires_in"
    case aispDescription = "in_app.connection.consents.aisp_description"
    case pispFutureDescription = "in_app.connection.consents.pisp_future_description"
    case pispRecurringDescription = "in_app.connection.consents.pisp_recurring_description"
    case consentGrantedTo = "in_app.connection.consents.granted_to"
    case sharedData = "in_app.connection.consents.shared_data"
    case balance = "in_app.connection.consents.balance"
    case transactions = "in_app.connection.consents.transactions"
    case granted = "in_app.connection.consents.granted"
    case expires = "in_app.connection.consents.expires"
    case accountNumber = "in_app.connection.consents.account_number"
    case sortCode = "in_app.connection.consents.sort_code"
    case iban = "in_app.connection.consents.iban"
    case revokeConsent = "in_app.connection.consents.revoke_consent"
    case revokeConsentDescription = "in_app.connection.consents.revoke_consent_description"
    case consentRevokedFor = "in_app.connection.consents.consent_revoked_for"

    // MARK: - Settings
    case settings = "in_app.sidebar_menu.settings"
    case deleteAll = "actions.delete_all"
    case deleteAllDataDescription = "actions.confirm_delete_connections"
    case search = "actions.search"
    case licenses = "in_app.settings.licenses"
    case enableNotifications = "in_app.settings.enable_notifications"
    case clearAllData = "in_app.settings.clear_all_data"
    case clearAppData = "in_app.settings.clear_app_data"
    case clearDataSuccessDescription = "in_app.settings.clear_app_data_success_message"
    case clearDataDescription = "in_app.settings.clear_app_data_description"

    // MARK: - Security
    case touchID = "in_app.settings.touch_id"
    case faceID = "in_app.settings.face_id"
    case passcode = "in_app.settings.passcode"
    case changePasscode = "actions.change_passcode"
    case wrongPasscodeSingular = "errors.passcode_ios_singular"
    case accountReset = "errors.account_reset"

    case createPasscode = "onboarding.secure_app.passcode_create"
    case confirmPasscode = "onboarding.secure_app.passcode_confirm"
    case newPasscode = "in_app.settings.new_passcode"
    case yourCurrentPasscode = "actions.current_passcode"
    case enterPasscodeOrUseTouchID = "in_app.passcode_confirmation.title"
    case enterPasscodeOrUseFaceID = "in_app.passcode_confirmation.title2"
    case newPasscodeSetSuccessMessage = "in_app.passcode_new_passcode_success_message"
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
    case errorOccuredPleaseTryAgain = "errors.authorization_error"
    case pleaseTryAgain = "errors.no_internet_connection_try_again"
    case inactivityMessage = "warnings.inactivity_block_message"
    case passcodeDontMatch = "errors.passcode_dont_match"
    case wrongPasscode = "errors.wrong_passcode"
    case biometricsNotAvailable = "in_app.settings.biometrics_not_available"
    case biometricsNotAvailableDescription = "in_app.settings.biometrics_not_available_message"

    // MARK: - Connection Options
    case connect = "actions.connect"
    case reconnect = "actions.reconnect"
    case rename = "actions.rename"
    case contactSupport = "in_app.settings.contact_support"
    case reportAnIssue = "actions.report_an_issue"
    case viewConsents = "actions.view_consents"

    // MARK: - Main Menu Options
    case viewConnections = "actions.view_connections"
    case viewSettings = "actions.view_settings"

    var localizedLabel: String { return self.rawValue }
}
