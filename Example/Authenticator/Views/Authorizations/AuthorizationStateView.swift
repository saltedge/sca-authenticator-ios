//
//  AuthorizationStateView
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

final class AuthorizationStateView: UIView {
    private let topView = UIView()
    private let titleLabel = UILabel.titleLabel
    private let messageLabel = UILabel.descriptionLabel
    private var accessoryView: UIView?

    enum AuthorizationState: String {
        case base
        case denied
        case expired
        case processing
        case success
        case undefined

        var title: String {
            switch self {
            case .base: return l10n(.active)
            case .success: return l10n(.successfulAuthorization)
            case .expired: return l10n(.timeOut)
            case .denied: return l10n(.denied)
            case .undefined: return l10n(.somethingWentWrong)
            default: return ""
            }
        }

        var message: String {
            switch self {
            case .base: return l10n(.activeMessage)
            case .success: return l10n(.successfulAuthorizationMessage)
            case .expired: return l10n(.timeOutMessage)
            case .denied: return l10n(.deniedMessage)
            case .undefined: return l10n(.pleaseTryAgain)
            default: return ""
            }
        }

        var topAccessoryView: UIView {
            switch self {
            case .success: return UIImageView(image: UIImage(named: "success"))
            case .expired: return UIImageView(image: UIImage(named: "time_out"))
            case .denied: return UIImageView(image: UIImage(named: "deny"))
            case .undefined: return UIImageView(image: UIImage(named: "smth_wrong"))
            default: return LoadingIndicator()
            }
        }
    }

    init(state: AuthorizationState) {
        super.init(frame: .zero)
        backgroundColor = .white
        layout()
    }

    func set(state: AuthorizationState) {
        messageLabel.text = state.message
        titleLabel.text = state.title
        setTopView(state: state)
    }

    func setTopView(state: AuthorizationState) {
        accessoryView?.removeFromSuperview()
        accessoryView = state.topAccessoryView
        if let accessoryView = self.accessoryView {
            topView.addSubview(accessoryView)
            accessoryView.centerInSuperview()
            accessoryView.size(AppLayout.loadingIndicatorSize)
        }
        if state == .processing, let loadingIndicator = accessoryView as? LoadingIndicator {
            loadingIndicator.start()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Layout
extension AuthorizationStateView: Layoutable {
    func layout() {
        addSubviews(messageLabel, titleLabel, topView)

        messageLabel.centerYToSuperview()
        messageLabel.leftToSuperview()
        messageLabel.rightToSuperview()

        titleLabel.leftToSuperview()
        titleLabel.rightToSuperview()
        titleLabel.bottomToTop(of: messageLabel, offset: -32)

        topView.centerXToSuperview()
        topView.bottomToTop(of: titleLabel, offset: -32)
        topView.size(AppLayout.loadingIndicatorSize)
    }
}
