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
    static let connectionImageSize: CGSize = CGSize(width: 25.0, height: 25.0)
    static let sideOffset: CGFloat = AppLayout.sideOffset / 2
    static let topOffset: CGFloat = 20.0
    static let buttonHeight: CGFloat = 36.0
    static let bottomOffset: CGFloat = -24.0
    static let titleLableHeight: CGFloat = 23.0
    static let contentStackViewMinTopBottomOffset: CGFloat = 27.5
    static let contentStackViewCenterYOffset: CGFloat = -20.0
    static let loadingPlaceholderHeight: CGFloat = 100.0
}

protocol AuthorizationCellDelegate: class {
    func confirmPressed(_ cell: AuthorizationCollectionViewCell)
    func denyPressed(_ cell: AuthorizationCollectionViewCell)
}

final class AuthorizationCollectionViewCell: UICollectionViewCell {
    private let loadingPlaceholder = UIView()
    private let loadingIndicator = LoadingIndicator()
    private let stateView = AuthorizationStateView(state: .none)
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

    private var constraintsToDeactivateOnProcessing: Constraints?

    weak var delegate: AuthorizationCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        descriptionTextView.isUserInteractionEnabled = false
        setupLeftButton()
        setupRightButton()
        setupLoadingView()
        layout()
    }

    func set(with viewModel: AuthorizationViewModel, success: Bool = false) {
        self.viewModel = viewModel

        if success {
            stateView.set(state: .success)
        } else if viewModel.expired {
            stateView.set(state: .timeOut)
        } else {
            stateView.set(state: .none)
        }

        stopProcessingIfNeeded()

        titleLabel.text = viewModel.title

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

    func setProcessing(with title: String) {
        if !isProcessing {
            titleLabel.text = title
            contentStackView.insertArrangedSubview(loadingPlaceholder, at: 0)
            if let constraintsToDeactivate = constraintsToDeactivateOnProcessing {
                constraintsToDeactivate.deActivate()
                layoutIfNeeded()
            }
            buttonsStackView.isHidden = true
            loadingIndicator.start()
            isProcessing = true
        }
    }

    private func setupLoadingView() {
        loadingPlaceholder.addSubview(loadingIndicator)
        loadingIndicator.top(to: loadingPlaceholder)
        loadingIndicator.centerX(to: loadingPlaceholder)
        loadingPlaceholder.height(Layout.loadingPlaceholderHeight)
    }

    private func stopProcessingIfNeeded() {
        if isProcessing {
            contentStackView.removeArrangedSubview(loadingPlaceholder)
            if let constraintsToDeactivate = constraintsToDeactivateOnProcessing {
                constraintsToDeactivate.activate()
                layoutIfNeeded()
            }
            buttonsStackView.isHidden = false
            // NOTE: Add start loading indicator in the status view
            loadingIndicator.stop()
            isProcessing = false
            viewModel.state = .success
        }
    }

    deinit {
        loadingIndicator.stop()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension AuthorizationCollectionViewCell {
    func setupLeftButton() {
        setupButton(.bordered, title: l10n(.deny)).addTarget(self, action: #selector(denyButtonPressed(_:)), for: .touchUpInside)
    }

    func setupRightButton() {
        setupButton(.filled, title: l10n(.allow)).addTarget(self, action: #selector(confirmButtonPressed(_:)), for: .touchUpInside)
    }

    func setupButton(_ style: CustomButton.Style, title: String) -> UIButton {
        let button = CustomButton(style, text: title, height: Layout.buttonHeight)
        button.titleLabel?.font = style == .filled ? .auth_15semibold : .auth_15medium
        buttonsStackView.addArrangedSubview(button)
        return button
    }
}

// MARK: - Actions
private extension AuthorizationCollectionViewCell {
    @objc func denyButtonPressed(_ sender: CustomButton) {
        setProcessing(with: l10n(.processing))
        stateView.set(state: .denied)
        // NOTE: Move logit to working with authorization id
        delegate?.denyPressed(self)
        viewModel.state = .denied
    }

    @objc func confirmButtonPressed(_ sender: CustomButton) {
        stateView.set(state: .active)
        // NOTE: Move logit to working with authorization id
        delegate?.confirmPressed(self)
    }
}

// MARK: - Layout
extension AuthorizationCollectionViewCell: Layoutable {
    func layout() {
        addSubviews(titleLabel, contentStackView, buttonsStackView)

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

        let bottomConstraint = buttonsStackView.topToBottom(
            of: contentStackView,
            offset: Layout.contentStackViewMinTopBottomOffset,
            relation: .equalOrGreater
        )

        let topConstraint = contentStackView.topToBottom(
            of: titleLabel,
            offset: Layout.contentStackViewMinTopBottomOffset,
            relation: .equalOrGreater
        )

        constraintsToDeactivateOnProcessing = [topConstraint, bottomConstraint]

        loadingIndicator.size(AppLayout.loadingIndicatorSize)

        addSubview(stateView)
        stateView.topToSuperview()
        stateView.bottomToSuperview()
        stateView.leftToSuperview()
        stateView.rightToSuperview()
    }
}
