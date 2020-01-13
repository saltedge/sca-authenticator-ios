//
//  AuthorizationCollectionViewCell
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
import TinyConstraints
import WebKit

private struct Layout {
    static let sideOffset: CGFloat = AppLayout.sideOffset / 2
    static let topOffset: CGFloat = 20.0
    static let buttonHeight: CGFloat = 36.0
    static let bottomOffset: CGFloat = -24.0
}

protocol AuthorizationCellDelegate: class {
    func confirmPressed(_ authorizationId: String)
    func denyPressed(_ authorizationId: String)
}

final class AuthorizationCollectionViewCell: UICollectionViewCell {
    private let stateView = AuthorizationStateView(state: .base)
    private var isProcessing: Bool = false

    private let titleLabel = UILabel.titleLabel
    private lazy var descriptionTextView = UITextView()
    private lazy var webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    private var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Layout.sideOffset
        return stackView
    }()
    private var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = Layout.sideOffset
        return stackView
    }()

    private(set) var viewModel: AuthorizationViewModel!

    weak var delegate: AuthorizationCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        descriptionTextView.isUserInteractionEnabled = false
        setupLeftButton()
        setupRightButton()
        layout()
    }

    func set(with viewModel: AuthorizationViewModel) {
        self.viewModel = viewModel

        guard viewModel.state == .none else {
            stateView.set(state: viewModel.state)
            stateView.isHidden = false
            return
        }

        if viewModel.expired && viewModel.state != .expired {
            stateView.set(state: .expired)
            stateView.isHidden = false
        } else {
            stateView.isHidden = true
            stateView.set(state: .base)

            if viewModel.description.htmlToAttributedString != nil {
                contentStackView.removeArrangedSubview(descriptionTextView)
                webView.loadHTMLString(viewModel.description, baseURL: nil)
                contentStackView.addArrangedSubview(webView)
            } else {
                contentStackView.removeArrangedSubview(webView)
                descriptionTextView.text = viewModel.description
                contentStackView.addArrangedSubview(descriptionTextView)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension AuthorizationCollectionViewCell {
    func setupLeftButton() {
        setupButton(
            .bordered,
            title: l10n(.deny)
        ).addTarget(self, action: #selector(denyButtonPressed(_:)), for: .touchUpInside)
    }

    func setupRightButton() {
        setupButton(
            .filled,
            title: l10n(.allow)
        ).addTarget(self, action: #selector(confirmButtonPressed(_:)), for: .touchUpInside)
    }

    func setupButton(_ style: CustomButton.Style, title: String) -> UIButton {
        let button = CustomButton(style, text: title, height: Layout.buttonHeight)
        buttonsStackView.addArrangedSubview(button)
        return button
    }
}

// MARK: - Actions
private extension AuthorizationCollectionViewCell {
    @objc func denyButtonPressed(_ sender: CustomButton) {
        delegate?.denyPressed(viewModel.authorizationId)
    }

    @objc func confirmButtonPressed(_ sender: CustomButton) {
        delegate?.confirmPressed(viewModel.authorizationId)
    }
}

// MARK: - Layout
extension AuthorizationCollectionViewCell: Layoutable {
    func layout() {
        addSubviews(titleLabel, contentStackView, buttonsStackView, stateView)

        titleLabel.top(to: self, offset: Layout.topOffset)
        titleLabel.centerX(to: self)
        titleLabel.textColor = .lightGray

        contentStackView.topToBottom(of: titleLabel, offset: 12.0)
        contentStackView.left(to: self, offset: AppLayout.sideOffset)
        contentStackView.right(to: self, offset: -AppLayout.sideOffset)
        contentStackView.bottomToTop(of: buttonsStackView)

        buttonsStackView.left(to: self, offset: AppLayout.sideOffset / 2)
        buttonsStackView.right(to: self, offset: -AppLayout.sideOffset / 2)
        buttonsStackView.bottom(to: self, offset: Layout.bottomOffset)

        stateView.edgesToSuperview()
    }
}
