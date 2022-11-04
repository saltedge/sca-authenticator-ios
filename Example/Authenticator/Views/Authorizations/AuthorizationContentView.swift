//
//  AuthorizationContentView.swift
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

private struct Layout {
    static let sideOffset: CGFloat = 16.0
    static let titleLabelTopOffset: CGFloat = 30.0
    static let contentTopOffset: CGFloat = 12.0
    static let bottomOffset: CGFloat = 40.0
}

final class AuthorizationContentView: UIView {
    private lazy var stateView = AuthorizationStateView(state: .base)
    private var isProcessing: Bool = false

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24.0, weight: .regular)
        label.textColor = .titleColor
        label.textAlignment = .center
        label.numberOfLines = 4
        return label
    }()

    private lazy var descriptionTextView = UITextView()
    private lazy var attributesStackView = AuthorizationContentDynamicStackView()
    private lazy var webView = ContentWebView()
    private var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Layout.sideOffset
        stackView.distribution = .fillProportionally
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
    // NOTE: Temporarily inactive due to legal restrictions
    // private let locationWarningLabel = UILabel(font: .systemFont(ofSize: 18.0, weight: .regular), textColor: .redAlert)

    var viewModel: AuthorizationDetailViewModel! {
        didSet {
            titleLabel.text = viewModel.title

            // NOTE: Temporarily inactive due to legal restrictions
            // if viewModel.showLocationWarning {
            //    locationWarningLabel.text = l10n(.locationWarning)
            // }
            // buttonsStackView.isHidden = viewModel.showLocationWarning
            // locationWarningLabel.isHidden = !viewModel.showLocationWarning

            guard viewModel.state.value == .base else {
                stateView.set(state: viewModel.state.value)
                return
            }

            if viewModel.expired && viewModel.state.value != .timeOut {
                stateView.set(state: .timeOut)
            } else {
                stateView.set(state: .base)

                if viewModel.apiVersion == "1" {
                    setupContentV1()
                } else {
                    setupContentV2(using: viewModel.descriptionAttributes)
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

    private func setupContentV1() {
        if viewModel.description.htmlToAttributedString != nil {
            setupWebView(content: viewModel.description)
        } else {
            contentStackView.removeArrangedSubview(webView)
            descriptionTextView.text = viewModel.description
            contentStackView.addArrangedSubview(descriptionTextView)
        }
    }

    private func setupContentV2(using attributes: [String: Any]) {
        if let html = attributes["html"] as? String {
            setupWebView(content: html)
        } else {
            contentStackView.removeAllArrangedSubviews()

            let attributesScrollView = UIScrollView()
            attributesScrollView.addSubview(attributesStackView)

            contentStackView.addArrangedSubview(attributesScrollView)

            attributesScrollView.edgesToSuperview()

            attributesStackView.width(to: attributesScrollView)
            attributesStackView.edgesToSuperview()

            attributesStackView.setup(using: attributes)
        }
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

    func setupWebView(content: String) {
        let supportDarkCSS = "<style>:root { color-scheme: light dark; }</style>"

        contentStackView.removeAllArrangedSubviews()
        webView.loadHTMLString(content + supportDarkCSS, baseURL: nil)

        contentStackView.addArrangedSubview(webView)
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
        addSubviews(titleLabel, contentStackView, buttonsStackView, stateView) // locationWarningLabel

        addSubviews(titleLabel, contentStackView, buttonsStackView, stateView)

        titleLabel.top(to: self, offset: Layout.titleLabelTopOffset)
        titleLabel.centerX(to: self)
        titleLabel.leftToSuperview(offset: Layout.sideOffset)
        titleLabel.rightToSuperview(offset: -Layout.sideOffset, relation: .equalOrLess)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        contentStackView.topToBottom(of: titleLabel, offset: Layout.contentTopOffset)
        contentStackView.leftToSuperview(offset: Layout.sideOffset)
        contentStackView.rightToSuperview(offset: -Layout.sideOffset)
        contentStackView.bottomToTop(of: buttonsStackView, offset: -Layout.sideOffset)
        contentStackView.centerXToSuperview()

        buttonsStackView.leftToSuperview(offset: Layout.sideOffset)
        buttonsStackView.rightToSuperview(offset: -Layout.sideOffset)
        buttonsStackView.bottom(to: self, safeAreaLayoutGuide.bottomAnchor, offset: -Layout.bottomOffset)
        buttonsStackView.centerXToSuperview()

        // NOTE: Temporarily inactive due to legal restrictions
        // locationWarningLabel.leftToSuperview(offset: Layout.sideOffset)
        // locationWarningLabel.rightToSuperview(offset: -Layout.sideOffset)
        // locationWarningLabel.bottom(to: self, safeAreaLayoutGuide.bottomAnchor, offset: -Layout.bottomOffset)
        // locationWarningLabel.centerXToSuperview()

        stateView.edgesToSuperview()
    }
}
