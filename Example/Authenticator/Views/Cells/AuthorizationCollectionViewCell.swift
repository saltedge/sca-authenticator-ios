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
    static let sideOffset: CGFloat = 16.0
    static let titleLabelTopOffset: CGFloat = 30.0
    static let contentTopOffset: CGFloat = 12.0
    static let bottomOffset: CGFloat = 40.0
}

protocol AuthorizationCellDelegate: class {
    func confirmPressed(_ authorizationId: String)
    func denyPressed(_ authorizationId: String)
}

final class AuthorizationCollectionViewCell: UICollectionViewCell {
    private lazy var stateView = AuthorizationStateView(state: .base)
    private var isProcessing: Bool = false

    private let titleLabel = UILabel(font: .systemFont(ofSize: 24.0, weight: .regular), textColor: .titleColor)
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
        stackView.spacing = 11.0
        return stackView
    }()

    var viewModel: AuthorizationDetailViewModel! {
        didSet {
            titleLabel.text = viewModel.title

            guard viewModel.state.value == .base else {
                stateView.set(state: viewModel.state.value)
                return
            }

            if viewModel.expired && viewModel.state.value != .expired {
                stateView.set(state: .expired)
            } else {
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

            viewModel.state.valueChanged = { value in
                self.stateView.set(state: value)
            }
        }
    }

    weak var delegate: AuthorizationCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        stateView.set(state: .base)
        descriptionTextView.isUserInteractionEnabled = false
        setupButtons()
        layout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension AuthorizationCollectionViewCell {
    func setupButtons() {
        let leftButton = CustomButton(text: l10n(.deny), textColor: .titleColor, backgroundColor: .secondaryBackground)
        leftButton.addTarget(self, action: #selector(denyButtonPressed(_:)), for: .touchUpInside)

        let rightButton = CustomButton(text: l10n(.allow), backgroundColor: .actionColor)
        rightButton.addTarget(self, action: #selector(confirmButtonPressed(_:)), for: .touchUpInside)

        buttonsStackView.addArrangedSubviews(leftButton, rightButton)
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

        titleLabel.top(to: self, offset: Layout.titleLabelTopOffset)
        titleLabel.centerX(to: self)

        contentStackView.topToBottom(of: titleLabel, offset: Layout.contentTopOffset)
        contentStackView.leftToSuperview(offset: Layout.sideOffset)
        contentStackView.rightToSuperview(offset: -Layout.sideOffset)
        contentStackView.bottomToTop(of: buttonsStackView)
        contentStackView.centerXToSuperview()

        buttonsStackView.leftToSuperview(offset: Layout.sideOffset)
        buttonsStackView.rightToSuperview(offset: -Layout.sideOffset)
        buttonsStackView.bottom(to: self, safeAreaLayoutGuide.bottomAnchor, offset: -Layout.bottomOffset)
        buttonsStackView.centerXToSuperview()

        stateView.edgesToSuperview()
    }
}
