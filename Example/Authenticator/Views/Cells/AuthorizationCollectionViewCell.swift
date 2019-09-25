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
    func confirmPressed(_ cell: AuthorizationCollectionViewCell)
    func denyPressed(_ cell: AuthorizationCollectionViewCell)
}

final class AuthorizationCollectionViewCell: UICollectionViewCell {
    private let loadingPlaceholder = UIView()
    private let loadingIndicator = LoadingIndicator()
    private var isProcessing: Bool = false

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

    private(set) var viewModel: AuthorizationViewModel!

    private var constraintsToDeactivateOnProcessing: Constraints?

    weak var delegate: AuthorizationCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLeftButton()
        setupRightButton()
        setupLoadingView()
        layout()
    }

    func set(with viewModel: AuthorizationViewModel) {
        self.viewModel = viewModel

        stopProcessingIfNeeded()

        titleLabel.text = viewModel.title

        if let htmlText = viewModel.description.htmlToAttributedString {
            descriptionLabel.attributedText = htmlText
        } else {
            descriptionLabel.text = viewModel.description
        }
        contentStackView.addArrangedSubview(descriptionLabel)
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
private extension AuthorizationCollectionViewCell {
    func setupLeftButton() {
        setupButton(.bordered, title: l10n(.deny)).addTarget(self, action: #selector(denyButtonPressed(_:)), for: .touchUpInside)
    }

    func setupRightButton() {
        setupButton(.filled, title: "Confirm").addTarget(self, action: #selector(confirmButtonPressed(_:)), for: .touchUpInside)
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
        delegate?.denyPressed(self)
    }

    @objc func confirmButtonPressed(_ sender: CustomButton) {
        delegate?.confirmPressed(self)
    }
}

// MARK: - Helpers
private extension AuthorizationCollectionViewCell {
    func diffInSecondsFromNow(for date: Date) -> Int {
        let currentDate = Date()
        let diffDateComponents = Calendar.current.dateComponents([.minute, .second], from: currentDate, to: date)

        guard let minutes = diffDateComponents.minute, let seconds = diffDateComponents.second else { return 0 }

        return 60 * minutes + seconds
    }
}

// MARK: - Layout
extension AuthorizationCollectionViewCell: Layoutable {
    func layout() {
        addSubviews(titleLabel, contentStackView, buttonsStackView)

        titleLabel.top(to: self, offset: Layout.topOffset)
        titleLabel.centerX(to: self)

        contentStackView.topToBottom(of: titleLabel, offset: 12.0)
        contentStackView.left(to: self, offset: AppLayout.sideOffset)
        contentStackView.right(to: self, offset: -AppLayout.sideOffset)

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
    }
}
