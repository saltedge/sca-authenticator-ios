//
//  AuthorizationContentView
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2020 Salt Edge Inc.
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
import WebKit

private struct Layout {
    static let sideOffset: CGFloat = 16.0
    static let titleLabelTopOffset: CGFloat = 30.0
    static let contentTopOffset: CGFloat = 12.0
    static let bottomOffset: CGFloat = 40.0
}

final class AuthorizationContentView: UIView {
    private lazy var stateView = AuthorizationStateView(state: .base)
    private var isProcessing: Bool = false

    private let titleLabel = UILabel(font: .systemFont(ofSize: 24.0, weight: .regular), textColor: .titleColor)
    private lazy var descriptionTextView = UITextView()
    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.layer.masksToBounds = true
        webView.layer.cornerRadius = 4.0
        return webView
    }()
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
        stackView.spacing = 11.0
        return stackView
    }()
    private let locationWarningLabel = UILabel(font: .systemFont(ofSize: 24.0, weight: .regular), textColor: .redAlert)

    var viewModel: AuthorizationDetailViewModel! {
        didSet {
            titleLabel.text = viewModel.title

            buttonsStackView.isHidden = !viewModel.showLocationWarning
            locationWarningLabel.isHidden = viewModel.showLocationWarning

            guard viewModel.state.value == .base else {
                stateView.set(state: viewModel.state.value)
                return
            }

            if viewModel.expired && viewModel.state.value != .expired {
                stateView.set(state: .expired)
            } else {
                stateView.set(state: .base)

                if viewModel.description.htmlToAttributedString != nil {
                    let supportDarkCSS = "<style>:root { color-scheme: light dark; }</style>"

                    contentStackView.removeArrangedSubview(descriptionTextView)
                    webView.loadHTMLString(viewModel.description + supportDarkCSS, baseURL: nil)
                    contentStackView.addArrangedSubview(webView)
                } else {
                    contentStackView.removeArrangedSubview(webView)
                    descriptionTextView.text = viewModel.description
                    contentStackView.addArrangedSubview(descriptionTextView)
                }
            }

            viewModel.state.valueChanged = { value in
                self.stateView.set(state: value)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        stateView.set(state: .base)
        contentStackView.layer.masksToBounds = true
        contentStackView.layer.cornerRadius = 6.0
        descriptionTextView.backgroundColor = .backgroundColor
        descriptionTextView.isUserInteractionEnabled = false
        setupButtons()
        layout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension AuthorizationContentView {
    func setupButtons() {
        let leftButton = CustomButton(text: l10n(.deny), textColor: .titleColor, backgroundColor: .secondaryBackground)
        leftButton.addTarget(self, action: #selector(denyButtonPressed(_:)), for: .touchUpInside)

        let rightButton = CustomButton(text: l10n(.allow), backgroundColor: .actionColor)
        rightButton.addTarget(self, action: #selector(confirmButtonPressed(_:)), for: .touchUpInside)

        buttonsStackView.addArrangedSubviews(leftButton, rightButton)
    }
}

// MARK: - Actions
private extension AuthorizationContentView {
    @objc func denyButtonPressed(_ sender: CustomButton) {
        viewModel.denyPressed()
    }

    @objc func confirmButtonPressed(_ sender: CustomButton) {
        viewModel.confirmPressed()
    }
}

// MARK: - Layout
extension AuthorizationContentView: Layoutable {
    func layout() {
        addSubviews(titleLabel, contentStackView, buttonsStackView, stateView)

        titleLabel.top(to: self, offset: Layout.titleLabelTopOffset)
        titleLabel.centerX(to: self)

        contentStackView.topToBottom(of: titleLabel, offset: Layout.contentTopOffset)
        contentStackView.leftToSuperview(offset: Layout.sideOffset)
        contentStackView.rightToSuperview(offset: -Layout.sideOffset)
        contentStackView.bottomToTop(of: buttonsStackView, offset: -Layout.sideOffset)
        contentStackView.centerXToSuperview()

        buttonsStackView.leftToSuperview(offset: Layout.sideOffset)
        buttonsStackView.rightToSuperview(offset: -Layout.sideOffset)
        buttonsStackView.bottom(to: self, safeAreaLayoutGuide.bottomAnchor, offset: -Layout.bottomOffset)
        buttonsStackView.centerXToSuperview()
        
        locationWarningLabel.text = l10n(.locationWarning)
        locationWarningLabel.leftToSuperview(offset: Layout.sideOffset)
        locationWarningLabel.rightToSuperview(offset: -Layout.sideOffset)
        locationWarningLabel.bottom(to: self, safeAreaLayoutGuide.bottomAnchor, offset: -Layout.bottomOffset)
        locationWarningLabel.centerXToSuperview()

        stateView.edgesToSuperview()
    }
}
