//
//  AuthorizationModalView.swift
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

protocol AuthorizationModalViewDelegate: class {
    func leftButtonPressed(_ view: AuthorizationModalView)
    func rightButtonPressed(_ view: AuthorizationModalView)
}

private struct Layout {
    static let connectionImageSize: CGSize = CGSize(width: 52.0, height: 52.0)
    static let sideOffset: CGFloat = AppLayout.sideOffset / 2
    static let topOffset: CGFloat = 15.0
    static let bottomOffset: CGFloat = -22.5
    static let contentTopOffset: CGFloat = 30.0
    static let interItemContentOffset = 15.0
    static let contentBottomOffset: CGFloat = 23.0
    static let titleLableHeight: CGFloat = 23.0
    static let buttonHeight: CGFloat = 42.0
    static let loadingPlaceholderHeight: CGFloat = 100.0
    static let descriptionViewUpdatedHeight: CGFloat = 88.0
    static let buttonsTopOffset: CGFloat = 27.5
    static let closeButtonSize: CGSize = CGSize(width: 16.0, height: 16.0)
    static let statusImageViewSize: CGSize = CGSize(width: 80.0, height: 80.0)
}

final class AuthorizationModalView: ModalView {
    weak var delegate: AuthorizationModalViewDelegate?

    private var connectionContentView = ConnectionContentView()
    private let closeButton = UIButton(type: .custom)
    private var timeLeftView: TimeLeftView!

    private let titleLabel = UILabel.titleLabel

    private lazy var webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    private lazy var descriptionTextView = UITextView()

    private var contentStackView = UIStackView()

    private let statusPlaceholder = UIView()
    private let loadingIndicator = LoadingIndicator()
    private let statusImageView = UIImageView()

    private var buttonsStackView: UIStackView!
    private var viewModel: AuthorizationViewModel!

    private var constraintsToDeactivateOnProcessing: Constraints?

    init(presentationDelegate: ModalViewPresentation) {
        super.init(presentationDelegate: presentationDelegate)
        setupContentStackView()
        setupButtonsStackView()
        setupDescriptionTextView()
        closeButton.setBackgroundImage(#imageLiteral(resourceName: "close"), for: .normal)
        closeButton.adjustsImageWhenHighlighted = false
        closeButton.addTarget(self, action: #selector(closePressed(_:)), for: .touchUpInside)
    }

    func set(with viewModel: AuthorizationViewModel) {
        self.viewModel = viewModel

        timeLeftView = TimeLeftView(
            secondsLeft: diffInSecondsFromNow(for: viewModel.authorizationExpiresAt),
            lifetime: viewModel.lifetime,
            completion: { [weak self] in
                guard let weakSelf = self else { return }

                UIView.animate(
                    withDuration: 0.3,
                    animations: {
                        weakSelf.contentStackView.removeArrangedSubview(weakSelf.connectionContentView)
                        weakSelf.connectionContentView.removeFromSuperview()
                        weakSelf.contentStackView.insertArrangedSubview(weakSelf.statusPlaceholder, at: 0)
                        weakSelf.buttonsStackView.isHidden = true
                        weakSelf.timeLeftView.alpha = 0.0
                    }
                )
                weakSelf.closed(with: l10n(.authorizationExpired), image: #imageLiteral(resourceName: "Error"))
            }
        )

        if let connection = ConnectionsCollector.with(id: viewModel.connectionId) {
            connectionContentView.set(title: connection.name, imageUrl: connection.logoUrl)
        }
        connectionContentView.height(Layout.loadingPlaceholderHeight)
        contentStackView.addArrangedSubview(connectionContentView)

        titleLabel.numberOfLines = 0
        titleLabel.text = viewModel.title
        contentStackView.addArrangedSubview(titleLabel)

        if viewModel.description.htmlToAttributedString != nil {
            descriptionTextView.isHidden = true
            webView.isHidden = false

            webView.loadHTMLString(viewModel.description, baseURL: nil)
            contentStackView.addArrangedSubview(webView)
        } else {
            descriptionTextView.isHidden = false
            webView.isHidden = true

            descriptionTextView.text = viewModel.description
            contentStackView.addArrangedSubview(descriptionTextView)
        }

        setupLeftButton()
        setupRightButton()

        layout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func processing(with text: String) {
        contentStackView.insertArrangedSubview(self.statusPlaceholder, at: 1)
        if let constraintsToDeactivate = constraintsToDeactivateOnProcessing {
            constraintsToDeactivate.deActivate()
        }
        contentStackView.centerY(to: self)
        layoutIfNeeded()

        buttonsStackView.removeFromSuperview()
        timeLeftView.removeFromSuperview()

        changeTitle(to: text)
        updateDescription()

        loadingIndicator.start()
    }

    func closed(with text: String, image: UIImage) {
        showFinalStatusImage(image)
        changeTitle(to: text)
        updateDescription()
        layoutIfNeeded()
    }

    func updateDescription() {
        descriptionTextView.setContentOffset(.zero, animated: false)
        descriptionTextView.textContainer.maximumNumberOfLines = 4
        descriptionTextView.textContainer.lineBreakMode = .byTruncatingTail
        descriptionTextView.height(Layout.descriptionViewUpdatedHeight)
    }

    private func changeTitle(to text: String) {
        titleLabel.text = text
    }
}

// MARK: - Setup
private extension AuthorizationModalView {
    func setupContentStackView() {
        contentStackView.axis = .vertical
        contentStackView.spacing = Layout.sideOffset
    }

    func setupDescriptionTextView() {
        descriptionTextView.font = .auth_15regular
        descriptionTextView.textColor = .auth_darkGray
        descriptionTextView.textAlignment = .center
        descriptionTextView.isEditable = false
    }

    func setupLeftButton() {
        setupButton(.bordered, title: l10n(.deny)).addTarget(self, action: #selector(leftButtonPressed(_:)), for: .touchUpInside)
    }

    func setupRightButton() {
        setupButton(
            .filled, title: l10n(.confirm)).addTarget(self, action: #selector(rightButtonPressed(_:)), for: .touchUpInside
        )
    }

    func setupButton(_ style: CustomButton.Style, title: String) -> UIButton {
        let button = CustomButton(style, text: title, height: Layout.buttonHeight)
        button.titleLabel?.font = .auth_17regular
        buttonsStackView.addArrangedSubview(button)
        return button
    }

    func setupButtonsStackView() {
        buttonsStackView = UIStackView()
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = Layout.sideOffset
    }
}

// MARK: - Actions
private extension AuthorizationModalView {
    @objc func closePressed(_ sender: UIButton) {
        _ = resignFirstResponder()
    }

    @objc func leftButtonPressed(_ sender: CustomButton) {
        delegate?.leftButtonPressed(self)
    }

    @objc func rightButtonPressed(_ sender: CustomButton) {
        delegate?.rightButtonPressed(self)
    }
}

// MARK: - Helpers
private extension AuthorizationModalView {
    func diffInSecondsFromNow(for date: Date) -> Int {
        let currentDate = Date()
        let diffDateComponents = Calendar.current.dateComponents([.minute, .second], from: currentDate, to: date)

        guard let minutes = diffDateComponents.minute, let seconds = diffDateComponents.second else { return 0 }

        return 60 * minutes + seconds
    }

    func showFinalStatusImage(_ image: UIImage) {
        statusImageView.image = image
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingIndicator.stop()
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.statusImageView.alpha = 1.0
            })
        })
    }
}

// MARK: - Layout
extension AuthorizationModalView: Layoutable {
    func layout() {
        addSubviews(closeButton, timeLeftView, contentStackView, buttonsStackView)

        closeButton.left(to: self, offset: Layout.sideOffset)
        closeButton.top(to: self, offset: Layout.topOffset)
        closeButton.size(Layout.closeButtonSize)

        timeLeftView.right(to: self, offset: -Layout.sideOffset)
        timeLeftView.centerY(to: closeButton)

        contentStackView.left(to: self, offset: Layout.sideOffset)
        contentStackView.right(to: self, offset: -Layout.sideOffset)

        let topConstraint = contentStackView.topToBottom(of: timeLeftView, offset: Layout.contentTopOffset)

        buttonsStackView.left(to: self, offset: AppLayout.sideOffset / 2)
        buttonsStackView.right(to: self, offset: -AppLayout.sideOffset / 2)
        buttonsStackView.bottom(to: self, offset: Layout.bottomOffset)

        let bottomConstraint = buttonsStackView.topToBottom(of: contentStackView, offset: Layout.buttonsTopOffset)

        constraintsToDeactivateOnProcessing = [topConstraint, bottomConstraint]

        statusPlaceholder.addSubviews(statusImageView, loadingIndicator)
        statusPlaceholder.height(Layout.loadingPlaceholderHeight)

        statusImageView.size(Layout.statusImageViewSize)
        statusImageView.top(to: statusPlaceholder)
        statusImageView.centerX(to: statusPlaceholder)
        statusImageView.alpha = 0.0

        loadingIndicator.size(AppLayout.loadingIndicatorSize)
        loadingIndicator.top(to: statusPlaceholder)
        loadingIndicator.centerX(to: statusPlaceholder)
    }
}

private final class ConnectionContentView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.auth_15medium
        label.textColor = .auth_cyan
        return label
    }()
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "bankPlaceholderCyanSmall")
        return imageView
    }()

    init() {
        super.init(frame: .zero)
        layout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(title: String, imageUrl: URL?) {
        titleLabel.text = title

        guard let url = imageUrl else { return }

        ConnectionImageHelper.setAnimatedCachedImage(from: url, for: imageView)
    }

    func layout() {
        addSubviews(imageView, titleLabel)

        imageView.size(Layout.connectionImageSize)
        imageView.top(to: self)
        imageView.centerX(to: self)

        titleLabel.topToBottom(of: imageView, offset: 15.0)
        titleLabel.centerX(to: imageView)
    }
}
