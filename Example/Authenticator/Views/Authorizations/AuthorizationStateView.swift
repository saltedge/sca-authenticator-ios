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

private struct Layout {
    static let topViewOffset: CGFloat = 72.0
    static let topViewSize: CGSize = CGSize(width: 75.0, height: 75.0)
    static let titleLabelTopOffset: CGFloat = 26.0
    static let messageLabelTopOffset: CGFloat = 10.0
}

final class AuthorizationStateView: UIView {
    private let topView = UIView()
    private let titleLabel = UILabel(font: .systemFont(ofSize: 21.0, weight: .regular), textColor: .titleColor)
    private let messageLabel = UILabel(font: .systemFont(ofSize: 17.0, weight: .regular), textColor: .titleColor)
    private var accessoryView: UIView?

    enum AuthorizationState: String, Equatable {
        case base
        case denied
        case expired
        case processing
        case success
        case undefined

        var title: String {
            switch self {
            case .processing: return l10n(.active)
            case .success: return l10n(.successfulAuthorization)
            case .expired: return l10n(.timeOut)
            case .denied: return l10n(.denied)
            case .undefined: return l10n(.somethingWentWrong)
            default: return ""
            }
        }

        var message: String {
            switch self {
            case .processing: return l10n(.activeMessage)
            case .success: return l10n(.successfulAuthorizationMessage)
            case .expired: return l10n(.timeOutMessage)
            case .denied: return l10n(.deniedMessage)
            case .undefined: return l10n(.pleaseTryAgain)
            default: return ""
            }
        }

        var topAccessoryView: UIView {
            switch self {
            case .success: return AspectFitImageView(imageName: "success")
            case .expired: return AspectFitImageView(imageName: "timeout")
            case .denied: return AspectFitImageView(imageName: "deny")
            case .undefined: return AspectFitImageView(imageName: "smth_wrong")
            default: return LoadingIndicator()
            }
        }

        static func == (lhs: AuthorizationState, rhs: AuthorizationState) -> Bool {
            switch (lhs, rhs) {
            case (.base, .base), (.denied, .denied), (.expired, .expired),
                 (.processing, .processing), (.success, .success), (.undefined, .undefined): return true
            default: return false
            }
        }
    }

    init(state: AuthorizationState) {
        super.init(frame: .zero)
        backgroundColor = .backgroundColor
        topView.layer.masksToBounds = true
        topView.layer.cornerRadius = 16.0
        topView.backgroundColor = .secondaryBackground
        layout()
    }

    func set(state: AuthorizationState) {
        guard state != .base else {
            self.alpha = 0.0
            return
        }

        alpha = 1.0
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
            accessoryView.size(CGSize(width: 55.0, height: 55.0))
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
        addSubviews(titleLabel, messageLabel, topView)

        topView.topToSuperview(offset: Layout.topViewOffset)
        topView.centerXToSuperview()
        topView.size(Layout.topViewSize)

        titleLabel.topToBottom(of: topView, offset: Layout.titleLabelTopOffset)
        titleLabel.centerXToSuperview()
        titleLabel.leftToSuperview()
        titleLabel.rightToSuperview()

        messageLabel.topToBottom(of: titleLabel, offset: Layout.messageLabelTopOffset)
        messageLabel.centerXToSuperview()
        messageLabel.leftToSuperview()
        messageLabel.rightToSuperview()
    }
}

class AspectFitImageView: UIImageView {
    init(imageName: String) {
        super.init(image: UIImage(named: imageName))
        contentMode = .scaleAspectFit
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
