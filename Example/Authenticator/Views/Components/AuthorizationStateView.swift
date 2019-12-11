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
        case none // default
        case active // confirm
        case success
        case timeOut
        case denied
        case undefined

        var title: String {
            switch self {
            case .active: return "Authorizing..."
            case .success: return "Success!"
            case .timeOut: return "Time Out"
            case .denied: return "Denied"
            case .undefined: return "Something went wrong"
            default: return ""
            }
        }

        var message: String {
            switch self {
            case .active: return "Please wait while authorization in process..."
            case .success: return "Ypur action was successfully authorized."
            case .timeOut: return "Time to authorize your action is out"
            case .denied: return "Your action was denied"
            case .undefined: return "Please try again."
            default: return ""
            }
        }

        var topAccessoryView: UIView {
            switch self {
            case .success: return UIImageView(image: UIImage(named: "success"))
            case .timeOut: return UIImageView(image: UIImage(named: "time_out"))
            case .denied: return UIImageView(image: UIImage(named: "deny"))
            case .undefined: return UIImageView(image: UIImage(named: "smth_wrong"))
            default: return LoadingIndicator()
            }
        }
    }

    init(state: AuthorizationState) {
        super.init(frame: .zero)
        layout()
        set(state: state)
    }

    func set(state: AuthorizationState) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            if state == .none {
                self?.alpha = 0.0
            } else {
                self?.alpha = 1.0
            }
        }

        messageLabel.text = state.message
        titleLabel.text = state.title
        setTopView(state: state)
    }

    func setTopView(state: AuthorizationState) {
        backgroundColor = .clear

        accessoryView?.removeFromSuperview()
        accessoryView = state.topAccessoryView
        if let accessoryView = self.accessoryView {
            topView.addSubview(accessoryView)
            accessoryView.centerInSuperview()
            accessoryView.size(AppLayout.loadingIndicatorSize)
        }
        if state == .active, let loadingIndicator = accessoryView as? LoadingIndicator {
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
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)

        addSubviews(blurEffectView, messageLabel, titleLabel, topView)

        messageLabel.centerYToSuperview()
        messageLabel.leftToSuperview()
        messageLabel.rightToSuperview()

        titleLabel.leftToSuperview()
        titleLabel.rightToSuperview()
        titleLabel.bottomToTop(of: messageLabel, offset: -32)

        topView.centerXToSuperview()
        topView.bottomToTop(of: titleLabel, offset: -32)
        topView.size(AppLayout.loadingIndicatorSize)

        blurEffectView.edgesToSuperview()
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
