//
//  AuthorizationCell.swift
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

private struct Layout {
    static let connectionImageSize: CGSize = CGSize(width: 25.0, height: 25.0)
    static let sideOffset: CGFloat = AppLayout.sideOffset / 2
    static let topOffset: CGFloat = 20.0
    static let buttonHeight: CGFloat = 36.0
    static let bottomOffset: CGFloat = -25.0
    static let titleLableHeight: CGFloat = 23.0
    static let contentStackViewMinTopBottomOffset: CGFloat = 27.5
    static let contentStackViewCenterYOffset: CGFloat = -20.0
    static let loadingPlaceholderHeight: CGFloat = 100.0
}

protocol AuthorizationCellDelegate: class {
    func leftButtonPressed(_ cell: AuthorizationCell)
    func rightButtonPressed(_ cell: AuthorizationCell)
    func timerExpired(_ cell: AuthorizationCell)
    func viewMorePressed(_ cell: AuthorizationCell)
}

final class AuthorizationCell: UITableViewCell, Dequeuable {
    weak var delegate: AuthorizationCellDelegate?

    private var timeLeftView: TimeLeftView!

    private let loadingPlaceholder = UIView()
    private let loadingIndicator = LoadingIndicator()
    private var isProcessing: Bool = false

    private let connectionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.auth_15medium
        label.textColor = .auth_cyan
        return label
    }()
    private var connectionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "bankPlaceholderCyanSmall")
        return imageView
    }()
    private let titleLabel = UILabel.titleLabel
    private let descriptionLabel = UILabel.descriptionLabel
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
    private var tapToViewMoreButton: UIButton!
    private(set) var viewModel: AuthorizationViewModel!

    private var constraintsToDeactivateOnProcessing: Constraints?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let maxLifetime = 0
        timeLeftView = TimeLeftView(
            secondsLeft: maxLifetime,
            lifetime: maxLifetime,
            completion: { [weak self] in
                guard let weakSelf = self else { return }

                weakSelf.delegate?.timerExpired(weakSelf)
            }
        )
        setupLoadingView()
        setupTapToViewMoreButton()
    }

    func set(with viewModel: AuthorizationViewModel) {
        self.viewModel = viewModel

        stopProcessingIfNeeded()

        timeLeftView.update(
            secondsLeft: diffInSecondsFromNow(for: viewModel.authorizationExpiresAt),
            lifetime: viewModel.lifetime
        )

        if let connection = ConnectionsCollector.with(id: viewModel.connectionId) {
            setImage(from: connection.logoUrl)
            connectionTitleLabel.text = connection.name
        }
        titleLabel.text = viewModel.title
        contentStackView.addArrangedSubview(titleLabel)

        if let htmlText = viewModel.description.htmlToAttributedString {
            descriptionLabel.attributedText = htmlText
        } else {
            descriptionLabel.text = viewModel.description
        }
        descriptionLabel.numberOfLines = 0
        contentStackView.addArrangedSubview(descriptionLabel)

        for button in buttonsStackView.arrangedSubviews {
            buttonsStackView.removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        setupLeftButton()
        setupRightButton()

        layout()
        layoutIfNeeded()
        if descriptionLabel.isTruncated {
            contentStackView.addArrangedSubview(tapToViewMoreButton)
        } else if contentStackView.arrangedSubviews.contains(tapToViewMoreButton) {
            contentStackView.removeArrangedSubview(tapToViewMoreButton)
            tapToViewMoreButton.removeFromSuperview()
        }
    }

    var shouldShowPopup: Bool {
        return descriptionLabel.isTruncated
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
            timeLeftView.isHidden = true
            tapToViewMoreButton.isHidden = true
            loadingIndicator.start()
            isProcessing = true
        }
    }

    private func setImage(from imageUrl: URL?) {
        guard let url = imageUrl else { return }

        guard ImageCacheManager.isImageCached(for: url) else {
            UIImage.from(url: url) { image in
                ImageCacheManager.cache(
                    image: image,
                    for: url,
                    completion: { cachedImage in
                        UIView.transition(
                            with: self.connectionImageView,
                            duration: 1.0,
                            options: [.curveEaseOut, .transitionCrossDissolve],
                            animations: {
                                self.connectionImageView.image = cachedImage
                            }
                        )
                    }
                )
            }
            return
        }

        if let connection = ConnectionsCollector.with(id: viewModel.connectionId) {
            connectionImageView.cachedImage(from: connection.logoUrl)
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
            timeLeftView.isHidden = false
            tapToViewMoreButton.isHidden = false
            loadingIndicator.stop()
            isProcessing = false
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
private extension AuthorizationCell {
    func setupTapToViewMoreButton() {
        tapToViewMoreButton = UIButton()
        tapToViewMoreButton.setTitleColor(.auth_blue, for: .normal)
        tapToViewMoreButton.titleLabel?.font = .auth_15medium
        tapToViewMoreButton.setTitle(l10n(.viewMore), for: .normal)
        tapToViewMoreButton.height(18.0)
        tapToViewMoreButton.addTarget(self, action: #selector(viewMoreButtonPressed(_:)), for: .touchUpInside)
    }

    func setupLeftButton() {
        setupButton(.bordered, title: l10n(.deny)).addTarget(self, action: #selector(leftButtonPressed(_:)), for: .touchUpInside)
    }

    func setupRightButton() {
        setupButton(.filled, title: "Confirm").addTarget(self, action: #selector(rightButtonPressed(_:)), for: .touchUpInside)
    }

    func setupButton(_ style: CustomButton.Style, title: String) -> UIButton {
        let button = CustomButton(style, text: title, height: Layout.buttonHeight)
        button.titleLabel?.font = style == .filled ? .auth_15semibold : .auth_15medium
        buttonsStackView.addArrangedSubview(button)
        return button
    }
}

// MARK: - Actions
private extension AuthorizationCell {
    @objc func leftButtonPressed(_ sender: CustomButton) {
        delegate?.leftButtonPressed(self)
    }

    @objc func rightButtonPressed(_ sender: CustomButton) {
        delegate?.rightButtonPressed(self)
    }

    @objc func viewMoreButtonPressed(_ sender: CustomButton) {
        delegate?.viewMorePressed(self)
    }
}

// MARK: - Helpers
private extension AuthorizationCell {
    func diffInSecondsFromNow(for date: Date) -> Int {
        let currentDate = Date()
        let diffDateComponents = Calendar.current.dateComponents([.minute, .second], from: currentDate, to: date)

        guard let minutes = diffDateComponents.minute, let seconds = diffDateComponents.second else { return 0 }

        return 60 * minutes + seconds
    }
}

// MARK: - Layout
extension AuthorizationCell: Layoutable {
    func layout() {
        addSubviews(connectionImageView, connectionTitleLabel, timeLeftView, contentStackView, buttonsStackView)

        connectionImageView.size(Layout.connectionImageSize)
        connectionImageView.left(to: self, offset: Layout.sideOffset)
        connectionImageView.top(to: self, offset: Layout.topOffset)

        connectionTitleLabel.leftToRight(of: connectionImageView, offset: Layout.sideOffset)
        connectionTitleLabel.centerY(to: connectionImageView)

        timeLeftView.right(to: self, offset: -Layout.sideOffset)
        timeLeftView.centerY(to: connectionImageView)

        buttonsStackView.left(to: self, offset: AppLayout.sideOffset / 2)
        buttonsStackView.right(to: self, offset: -AppLayout.sideOffset / 2)
        buttonsStackView.bottom(to: self, offset: Layout.bottomOffset)

        let bottomConstraint = buttonsStackView.topToBottom(
            of: contentStackView,
            offset: Layout.contentStackViewMinTopBottomOffset,
            relation: .equalOrGreater
        )

        let topConstraint = contentStackView.topToBottom(
            of: timeLeftView,
            offset: Layout.contentStackViewMinTopBottomOffset,
            relation: .equalOrGreater
        )

        contentStackView.left(to: contentView, offset: AppLayout.sideOffset)
        contentStackView.right(to: contentView, offset: -AppLayout.sideOffset)
        contentStackView.centerY(to: self, offset: Layout.contentStackViewCenterYOffset)

        constraintsToDeactivateOnProcessing = [topConstraint, bottomConstraint]

        titleLabel.height(Layout.titleLableHeight)

        loadingIndicator.size(AppLayout.loadingIndicatorSize)
    }
}

private extension UILabel {
    var isTruncated: Bool {
        guard let labelText = text else { return false }

        let labelTextSize = (labelText as NSString).boundingRect(
            with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil).size

        return labelTextSize.height > bounds.size.height
    }
}
