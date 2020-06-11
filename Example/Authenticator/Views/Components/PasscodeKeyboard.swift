//
//  PasscodeKeyboard.swift
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

protocol PasscodeKeyboardDelegate: class {
    func keyboard(didInputDigit digit: String)
    func forgotPressed()
    func clearPressed()
    func biometricsPressed()
}

private struct Layout {
    static let buttonSize: CGSize = CGSize(width: AppLayout.screenWidth * 0.304, height: AppLayout.screenHeight * 0.086)
}

final class PasscodeKeyboard: UIView {
    weak var delegate: PasscodeKeyboardDelegate?

    private let mainStackView = UIStackView(frame: .zero)
    private var actionButton = TaptileFeedbackButton()
    private var actionButtonImage: UIImage

    private struct Images {
        static let clearImage: UIImage = UIImage(named: "ClearButton", in: .authenticator_main, compatibleWith: nil)!
        static let biometricsImage: UIImage = BiometricsPresenter.keyboardImage!
    }

    var showClearButton: Bool = false {
        didSet {
            guard showClearButton != oldValue else { return }

            if showClearButton {
                UIView.transition(
                    with: self.actionButton,
                    duration: 0.4,
                    options: .transitionFlipFromRight,
                    animations: {
                        self.actionButton.set(image: Images.clearImage)
                    }
                )
            } else {
                UIView.transition(
                    with: self.actionButton,
                    duration: 0.4,
                    options: .transitionFlipFromRight,
                    animations: {
                        self.actionButton.set(image: Images.biometricsImage)
                    }
                )
            }
        }
    }

    init(shouldShowTouchID: Bool) {
        actionButtonImage = shouldShowTouchID ? Images.biometricsImage : Images.clearImage
        super.init(frame: .zero)
        let keyboardLayout: [[Any]] = [
            ["1", "4", "7", shouldShowTouchID ? l10n(.forgot) : ""],
            ["2", "5", "8", "0"],
            ["3", "6", "9", actionButton]
        ]
        setupMainStackView()
        for column in keyboardLayout {
            setupVerticalButtonsStackView(with: column)
        }
        layout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension PasscodeKeyboard {
    func setupMainStackView() {
        mainStackView.axis = .horizontal
        mainStackView.alignment = .center
        mainStackView.spacing = 0.0
        mainStackView.distribution = .fillEqually
    }

    func setupVerticalButtonsStackView(with array: [Any]) {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 0.0
        stackView.distribution = .fillProportionally
        for value in array {
            let button = createButton(with: value)
            button.size(Layout.buttonSize)
            stackView.addArrangedSubview(button)
        }
        mainStackView.addArrangedSubview(stackView)
    }

    func createButton(with value: Any) -> UIButton {
        var button = TaptileFeedbackButton()
        button.layer.cornerRadius = 6.0

        if let title = value as? String {
            button.setTitle(title, for: .normal)
            button.setTitleColor(.titleColor, for: .normal)
            if title == l10n(.forgot) {
                button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
            } else {
                button.titleLabel?.font = .systemFont(ofSize: 30, weight: .semibold)
            }
            button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        } else {
            actionButton.setImage(actionButtonImage, for: .normal)
            actionButton.setImage(actionButtonImage, for: .highlighted)
            actionButton.addTarget(self, action: #selector(actionButtonPressed(_:)), for: .touchUpInside)
            button = actionButton
        }
        return button
    }
}

// MARK: - Actions
private extension PasscodeKeyboard {
    @objc func buttonPressed(_ sender: TaptileFeedbackButton) {
        if let title = sender.title(for: .normal), !title.isEmpty {
            if title == l10n(.forgot) {
                delegate?.forgotPressed()
            } else {
                delegate?.keyboard(didInputDigit: title)
            }
        }
    }

    @objc func actionButtonPressed(_ sender: TaptileFeedbackButton) {
        if let image = sender.image(for: .normal) {
            if image == Images.clearImage {
                delegate?.clearPressed()
            } else {
                delegate?.biometricsPressed()
            }
        }
    }
}

// MARK: - Layout
extension PasscodeKeyboard: Layoutable {
    func layout() {
        addSubview(mainStackView)

        mainStackView.edges(to: self)
    }
}
